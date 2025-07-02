import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_config.dart';

class ApiService {
  static String _baseUrl = AppConfig.baseUrl;
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Flag to enable/disable API calls (set to false until Functions are deployed)
  static const bool _useFunctions = false;

  // Get profile data by slug for web viewer
  static Future<Map<String, dynamic>?> getProfileBySlug(
    String slug, {
    String? userId,
  }) async {
    if (!_useFunctions) {
      // Use Supabase directly until Functions are deployed
      return await _getProfileBySlugFromSupabase(slug, userId: userId);
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/profile/$slug'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return null; // Profile not found
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  // Check if a slug is available
  static Future<bool> isSlugAvailable(String slug) async {
    if (!_useFunctions) {
      // Use Supabase directly until Functions are deployed
      return await _isSlugAvailableFromSupabase(slug);
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/slug/check/$slug'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['available'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking slug availability: $e');
      return false;
    }
  }

  // Track QR scan/link visit
  static Future<void> trackVisit(String slug) async {
    if (!_useFunctions) {
      // Use Supabase directly until Functions are deployed
      return await _trackVisitToSupabase(slug);
    }

    try {
      await http.post(
        Uri.parse('$_baseUrl/api/track/$slug'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'timestamp': DateTime.now().toIso8601String(),
          'userAgent': 'web',
        }),
      );
    } catch (e) {
      print('Error tracking visit: $e');
      // Don't throw error for analytics failures
    }
  }

  // Supabase fallback methods (until Functions are deployed)
  static Future<Map<String, dynamic>?> _getProfileBySlugFromSupabase(
    String slug, {
    String? userId,
  }) async {
    try {
      // Get QR config by slug (and optionally by user ID for disambiguation)
      var query = _supabase
          .from('qr_configs')
          .select()
          .eq('link_slug', slug)
          .eq('is_active', true);

      // If userId is provided, filter by specific user
      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      final qrConfigResponse = await query.limit(1);

      if (qrConfigResponse.isEmpty) {
        return null;
      }

      final qrConfig = qrConfigResponse.first;

      // Check if expired
      if (qrConfig['expires_at'] != null) {
        final expiresAt = DateTime.parse(qrConfig['expires_at']);
        if (DateTime.now().isAfter(expiresAt)) {
          return null;
        }
      }

      // Get user profile
      final userResponse = await _supabase
          .from('users')
          .select()
          .eq('id', qrConfig['user_id'])
          .limit(1);

      if (userResponse.isEmpty) {
        return null;
      }

      final userData = userResponse.first;

      // Get custom links
      final selectedLinkIds = List<String>.from(
        qrConfig['selected_link_ids'] ?? [],
      );
      List<Map<String, dynamic>> customLinks = [];

      if (selectedLinkIds.isNotEmpty) {
        final linksResponse = await _supabase
            .from('custom_links')
            .select()
            .eq('user_id', qrConfig['user_id'])
            .inFilter('id', selectedLinkIds);

        customLinks =
            linksResponse
                .map<Map<String, dynamic>>(
                  (link) => {
                    'platform': _getPlatformFromUrl(link['url'] ?? ''),
                    'url': link['url'],
                    'label': link['display_name'],
                  },
                )
                .toList();
      }

      return {
        'name': userData['name'] ?? 'Anonymous User',
        'bio': userData['bio'] ?? '',
        'avatar': userData['profile_image_url'],
        'description': qrConfig['description'] ?? '',
        'links': customLinks,
        'scanCount': (qrConfig['scan_count'] ?? 0) + 1,
        'createdAt': qrConfig['created_at'],
      };
    } catch (e) {
      print('Error fetching profile from Supabase: $e');
      return null;
    }
  }

  static Future<bool> _isSlugAvailableFromSupabase(String slug) async {
    try {
      final response = await _supabase
          .from('qr_configs')
          .select('id')
          .eq('link_slug', slug)
          .limit(1);

      return response.isEmpty;
    } catch (e) {
      print('Error checking slug availability from Supabase: $e');
      return false;
    }
  }

  static Future<void> _trackVisitToSupabase(String slug) async {
    try {
      // Find the QR config
      final qrConfigResponse = await _supabase
          .from('qr_configs')
          .select('id')
          .eq('link_slug', slug)
          .limit(1);

      if (qrConfigResponse.isNotEmpty) {
        final configId = qrConfigResponse.first['id'];

        // Increment scan count using RPC function
        await _supabase.rpc(
          'increment_scan_count',
          params: {'config_id': configId},
        );

        // Track visit
        await _supabase.from('qr_visits').insert({
          'config_id': configId,
          'visited_at': DateTime.now().toIso8601String(),
          'user_agent': 'web',
        });
      }
    } catch (e) {
      print('Error tracking visit to Supabase: $e');
      // Don't throw error for analytics failures
    }
  }

  static String _getPlatformFromUrl(String url) {
    if (url.contains('instagram.com')) return 'instagram';
    if (url.contains('twitter.com') || url.contains('x.com')) return 'twitter';
    if (url.contains('linkedin.com')) return 'linkedin';
    if (url.contains('facebook.com')) return 'facebook';
    if (url.contains('youtube.com')) return 'youtube';
    if (url.contains('tiktok.com')) return 'tiktok';
    if (url.contains('github.com')) return 'github';
    if (url.contains('discord.')) return 'discord';
    if (url.contains('snapchat.com')) return 'snapchat';
    if (url.contains('pinterest.com')) return 'pinterest';
    if (url.contains('reddit.com')) return 'reddit';
    if (url.contains('wa.me') || url.contains('whatsapp.com')) {
      return 'whatsapp';
    }
    if (url.contains('t.me') || url.contains('telegram.')) return 'telegram';
    if (url.contains('mailto:')) return 'email';
    if (url.contains('tel:')) return 'phone';
    return 'website';
  }
}
