import 'dart:async';
import 'package:flutter/foundation.dart';
import 'supabase_service.dart';
import 'local_storage_service.dart';
import '../models/qr_link_config.dart';
import '../models/qr_preset.dart';

class CleanupService {
  final SupabaseService _supabaseService;
  final LocalStorageService _localStorageService;
  Timer? _periodicTimer;

  CleanupService({
    required SupabaseService supabaseService,
    required LocalStorageService localStorageService,
  }) : _supabaseService = supabaseService,
       _localStorageService = localStorageService;

  /// Initialize automatic cleanup
  void startPeriodicCleanup() {
    // Run cleanup every 15 minutes
    _periodicTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      _performCleanup();
    });

    // Also run initial cleanup
    _performCleanup();
  }

  /// Stop automatic cleanup
  void stopPeriodicCleanup() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// Perform comprehensive cleanup
  Future<void> _performCleanup() async {
    try {
      await Future.wait([
        _cleanupExpiredQrLinks(),
        _cleanupExpiredPresets(),
        _deactivateExpiredLinks(),
      ]);
    } catch (e) {
      debugPrint('Cleanup error: $e');
    }
  }

  /// Deactivate QR links that have expired
  Future<void> _deactivateExpiredLinks() async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) return;

      final configsStream = _supabaseService.getUserQrConfigs(userId);
      final configs = await configsStream.first;

      final expiredConfigs =
          configs
              .where((config) => config.isActive && config.isExpired)
              .toList();

      for (final config in expiredConfigs) {
        debugPrint('🔄 Deactivating expired QR link: ${config.linkSlug}');

        final updatedConfig = config.copyWith(
          isActive: false,
          updatedAt: DateTime.now(),
        );

        await _supabaseService.updateQrLinkConfig(updatedConfig);
      }

      if (expiredConfigs.isNotEmpty) {
        debugPrint('✅ Deactivated ${expiredConfigs.length} expired QR links');
      }
    } catch (e) {
      debugPrint('Error deactivating expired links: $e');
    }
  }

  /// Remove old inactive QR links (after 30 days)
  Future<void> _cleanupExpiredQrLinks() async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) return;

      final configsStream = _supabaseService.getUserQrConfigs(userId);
      final configs = await configsStream.first;

      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));

      final oldInactiveConfigs =
          configs
              .where(
                (config) =>
                    !config.isActive && config.updatedAt.isBefore(cutoffDate),
              )
              .toList();

      for (final config in oldInactiveConfigs) {
        debugPrint('🗑️ Removing old QR link: ${config.linkSlug}');
        await _supabaseService.deleteQrLinkConfig(config.id);
      }

      if (oldInactiveConfigs.isNotEmpty) {
        debugPrint('✅ Cleaned up ${oldInactiveConfigs.length} old QR links');
      }
    } catch (e) {
      debugPrint('Error cleaning up expired QR links: $e');
    }
  }

  /// Remove expired presets from local storage
  Future<void> _cleanupExpiredPresets() async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) return;

      final presets = await _localStorageService.getAllQrPresets(userId);
      final expiredPresets = <QrPreset>[];

      for (final preset in presets) {
        if (_isPresetExpired(preset)) {
          expiredPresets.add(preset);
        }
      }

      for (final preset in expiredPresets) {
        debugPrint('🗑️ Removing expired preset: ${preset.name}');
        await _localStorageService.deleteQrPreset(preset.id);
      }

      if (expiredPresets.isNotEmpty) {
        debugPrint('✅ Cleaned up ${expiredPresets.length} expired presets');
      }
    } catch (e) {
      debugPrint('Error cleaning up expired presets: $e');
    }
  }

  /// Check if a preset has expired based on its expiry settings
  bool _isPresetExpired(QrPreset preset) {
    final expiry = preset.expirySettings;
    final now = DateTime.now();

    // Check if expiry date has passed
    if (expiry.expiryDate != null && now.isAfter(expiry.expiryDate!)) {
      return true;
    }

    // Don't auto-remove presets based on scan count as they might be reused
    // Only remove based on time expiry

    return false;
  }

  /// Get QR links that are expiring soon (within 24 hours)
  Future<List<QrLinkConfig>> getExpiringSoonLinks() async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) return [];

      final configsStream = _supabaseService.getUserQrConfigs(userId);
      final configs = await configsStream.first;

      final expiringSoon = <QrLinkConfig>[];
      final tomorrow = DateTime.now().add(const Duration(hours: 24));

      for (final config in configs) {
        if (!config.isActive || config.isExpired) continue;

        // Check if expiring within 24 hours
        if (config.expirySettings.expiryDate != null) {
          final expiryDate = config.expirySettings.expiryDate!;
          if (expiryDate.isAfter(DateTime.now()) &&
              expiryDate.isBefore(tomorrow)) {
            expiringSoon.add(config);
          }
        }

        // Check if close to max scans (80% threshold)
        if (config.expirySettings.maxScans != null) {
          final threshold = (config.expirySettings.maxScans! * 0.8).ceil();
          if (config.scanCount >= threshold) {
            expiringSoon.add(config);
          }
        }
      }

      return expiringSoon;
    } catch (e) {
      debugPrint('Error getting expiring soon links: $e');
      return [];
    }
  }

  /// Get statistics about user's QR links
  Future<Map<String, int>> getQrLinkStats() async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) return {};

      final configsStream = _supabaseService.getUserQrConfigs(userId);
      final configs = await configsStream.first;

      int active = 0;
      int expired = 0;
      int expiringSoon = 0;
      int totalScans = 0;

      final tomorrow = DateTime.now().add(const Duration(hours: 24));

      for (final config in configs) {
        totalScans += config.scanCount;

        if (config.isExpired) {
          expired++;
        } else if (config.isActive) {
          active++;

          // Check if expiring soon
          if (config.expirySettings.expiryDate != null) {
            final expiryDate = config.expirySettings.expiryDate!;
            if (expiryDate.isAfter(DateTime.now()) &&
                expiryDate.isBefore(tomorrow)) {
              expiringSoon++;
            }
          }

          if (config.expirySettings.maxScans != null) {
            final threshold = (config.expirySettings.maxScans! * 0.8).ceil();
            if (config.scanCount >= threshold) {
              expiringSoon++;
            }
          }
        }
      }

      return {
        'total': configs.length,
        'active': active,
        'expired': expired,
        'expiring_soon': expiringSoon,
        'total_scans': totalScans,
      };
    } catch (e) {
      debugPrint('Error getting QR link stats: $e');
      return {};
    }
  }

  /// Manual cleanup method for immediate use
  Future<Map<String, int>> performManualCleanup() async {
    final stats = <String, int>{
      'deactivated_links': 0,
      'deleted_old_links': 0,
      'deleted_expired_presets': 0,
    };

    try {
      // Track what was cleaned
      final userId = _supabaseService.currentUserId;
      if (userId == null) return stats;

      // Get current state
      final configsStream = _supabaseService.getUserQrConfigs(userId);
      final configs = await configsStream.first;
      final presets = await _localStorageService.getAllQrPresets(userId);

      // Count what will be cleaned
      final expiredConfigs =
          configs.where((c) => c.isActive && c.isExpired).length;
      final oldInactiveConfigs =
          configs
              .where(
                (c) =>
                    !c.isActive &&
                    c.updatedAt.isBefore(
                      DateTime.now().subtract(const Duration(days: 30)),
                    ),
              )
              .length;
      final expiredPresets = presets.where(_isPresetExpired).length;

      // Perform cleanup
      await _performCleanup();

      // Return stats
      stats['deactivated_links'] = expiredConfigs;
      stats['deleted_old_links'] = oldInactiveConfigs;
      stats['deleted_expired_presets'] = expiredPresets;
    } catch (e) {
      debugPrint('Error in manual cleanup: $e');
    }

    return stats;
  }

  void dispose() {
    stopPeriodicCleanup();
  }
}
