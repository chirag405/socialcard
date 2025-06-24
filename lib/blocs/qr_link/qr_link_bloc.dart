import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../services/supabase_service.dart';
import '../../services/local_storage_service.dart';
import '../../utils/app_config.dart';
import 'qr_link_event.dart';
import 'qr_link_state.dart';

class QrLinkBloc extends Bloc<QrLinkEvent, QrLinkState> {
  final SupabaseService _supabaseService;
  final LocalStorageService _localStorageService;
  final Uuid _uuid = const Uuid();

  QrLinkBloc({
    required SupabaseService supabaseService,
    required LocalStorageService localStorageService,
  }) : _supabaseService = supabaseService,
       _localStorageService = localStorageService,
       super(QrLinkInitial()) {
    on<QrLinkLoadRequested>(_onLoadRequested);
    on<QrLinkCreateRequested>(_onCreateRequested);
    on<QrLinkUpdateRequested>(_onUpdateRequested);
    on<QrLinkDeleteRequested>(_onDeleteRequested);
    on<QrCustomizationUpdated>(_onCustomizationUpdated);
    on<ExpirySettingsUpdated>(_onExpirySettingsUpdated);
    on<SlugAvailabilityChecked>(_onSlugAvailabilityChecked);
    on<QrLinkShareRequested>(_onShared);
    on<QrLinkRegenerateRequested>(_onRegenerateRequested);
    on<LoadQrConfigs>(_onLoadQrConfigs);
    on<DeleteQrConfig>(_onDeleteQrConfig);
  }

  Future<void> _onLoadRequested(
    QrLinkLoadRequested event,
    Emitter<QrLinkState> emit,
  ) async {
    emit(QrLinkLoading());
    try {
      await emit.forEach(
        _supabaseService.getUserQrConfigs(event.userId),
        onData: (configs) {
          final activeConfig = configs.firstWhere(
            (config) => config.isActive && !config.isExpired,
            orElse: () => configs.first,
          );
          return QrLinkLoaded(
            configs,
            activeConfig: activeConfig.isActive ? activeConfig : null,
          );
        },
        onError: (error, stackTrace) {
          print('Error loading QR configs: $error');
          return QrLinkError('Failed to load QR configurations: $error');
        },
      );
    } catch (e) {
      emit(QrLinkError('Failed to load QR configurations: $e'));
    }
  }

  Future<void> _onCreateRequested(
    QrLinkCreateRequested event,
    Emitter<QrLinkState> emit,
  ) async {
    emit(QrLinkLoading());
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) {
        print('❌ QR Creation Error: User not authenticated');
        throw Exception('User not authenticated');
      }

      print('🔗 QR Creation: Starting for user $userId');

      // Generate a unique slug if not provided
      String slug = event.config.linkSlug;
      if (slug.isEmpty) {
        slug = _generateRandomSlug();
        print('🔗 QR Creation: Generated random slug: $slug');
      } else {
        print('🔗 QR Creation: Using provided slug: $slug');
      }

      // Enhanced slug availability check
      print('🔗 QR Creation: Checking slug availability...');
      bool isAvailable = await _supabaseService.isSlugAvailable(slug);
      if (!isAvailable) {
        print('❌ QR Creation Error: Slug "$slug" is not available');
        emit(
          const QrLinkError(
            'This custom link is already taken. Please choose another.',
          ),
        );
        return;
      }

      print('✅ QR Creation: Slug "$slug" is available');

      final newConfig = event.config.copyWith(
        id: _uuid.v4(),
        userId: userId,
        linkSlug: slug,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('🔗 QR Creation: Creating config with collision handling...');
      print('🔗 QR Creation: Config ID: ${newConfig.id}');
      print('🔗 QR Creation: Config Slug: ${newConfig.linkSlug}');
      print('🔗 QR Creation: Config User ID: ${newConfig.userId}');

      // Use the retry method to handle race conditions
      final finalConfig = await _supabaseService.createQrLinkConfigWithRetry(
        newConfig,
      );

      print('✅ QR Creation: Config saved successfully!');
      print('🔗 QR Creation: Final Slug: ${finalConfig.linkSlug}');
      print('🔗 QR Creation: Profile URL: ${finalConfig.shareableLink}');

      emit(QrLinkCreated(finalConfig));

      // Reload configs
      add(QrLinkLoadRequested(userId));
    } catch (e) {
      if (e is SlugCollisionException) {
        print('❌ QR Creation: Slug collision after retries: ${e.message}');
        emit(
          QrLinkError(
            'Unable to create QR code with the chosen slug. Please try a different one.',
          ),
        );
      } else {
        print('❌ QR Creation: General error: $e');
        emit(QrLinkError('Failed to create QR configuration: $e'));
      }
    }
  }

  Future<void> _onUpdateRequested(
    QrLinkUpdateRequested event,
    Emitter<QrLinkState> emit,
  ) async {
    try {
      await _supabaseService.updateQrLinkConfig(event.config);
      emit(QrLinkUpdated(event.config));

      // Reload configs
      if (_supabaseService.currentUserId != null) {
        add(QrLinkLoadRequested(_supabaseService.currentUserId!));
      }
    } catch (e) {
      emit(QrLinkError('Failed to update QR configuration: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    QrLinkDeleteRequested event,
    Emitter<QrLinkState> emit,
  ) async {
    try {
      await _supabaseService.deleteQrLinkConfig(event.configId);
      emit(QrLinkDeleted(event.configId));

      // Reload configs
      if (_supabaseService.currentUserId != null) {
        add(QrLinkLoadRequested(_supabaseService.currentUserId!));
      }
    } catch (e) {
      emit(QrLinkError('Failed to delete QR configuration: $e'));
    }
  }

  Future<void> _onCustomizationUpdated(
    QrCustomizationUpdated event,
    Emitter<QrLinkState> emit,
  ) async {
    if (state is QrLinkEditing) {
      final currentState = state as QrLinkEditing;
      emit(currentState.copyWith(customization: event.customization));
    }
  }

  Future<void> _onExpirySettingsUpdated(
    ExpirySettingsUpdated event,
    Emitter<QrLinkState> emit,
  ) async {
    if (state is QrLinkEditing) {
      final currentState = state as QrLinkEditing;
      emit(currentState.copyWith(expirySettings: event.settings));
    }
  }

  Future<void> _onSlugAvailabilityChecked(
    SlugAvailabilityChecked event,
    Emitter<QrLinkState> emit,
  ) async {
    try {
      final isAvailable = await _supabaseService.isSlugAvailable(event.slug);
      emit(SlugAvailabilityResult(event.slug, isAvailable));
    } catch (e) {
      emit(QrLinkError('Failed to check slug availability: $e'));
    }
  }

  Future<void> _onShared(
    QrLinkShareRequested event,
    Emitter<QrLinkState> emit,
  ) async {
    try {
      final config = await _supabaseService.getQrLinkConfig(event.configId);
      if (config != null) {
        emit(QrLinkSharing(config));

        // Generate the share link using app config
        final shareLink = AppConfig.generateProfileLink(config.linkSlug);
        emit(QrLinkShared(config, shareLink));
      } else {
        emit(const QrLinkError('Configuration not found'));
      }
    } catch (e) {
      emit(QrLinkError('Failed to share: $e'));
    }
  }

  Future<void> _onRegenerateRequested(
    QrLinkRegenerateRequested event,
    Emitter<QrLinkState> emit,
  ) async {
    try {
      final config = await _supabaseService.getQrLinkConfig(event.configId);
      if (config != null) {
        // Deactivate old config
        await _supabaseService.updateQrLinkConfig(
          config.copyWith(isActive: false, updatedAt: DateTime.now()),
        );

        // Create new config with same customization
        final newSlug = _generateRandomSlug();
        final newConfig = config.copyWith(
          id: _uuid.v4(),
          linkSlug: newSlug,
          scanCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _supabaseService.createQrLinkConfig(newConfig);
        emit(QrLinkCreated(newConfig));

        // Reload configs
        if (_supabaseService.currentUserId != null) {
          add(QrLinkLoadRequested(_supabaseService.currentUserId!));
        }
      }
    } catch (e) {
      emit(QrLinkError('Failed to regenerate QR configuration: $e'));
    }
  }

  Future<void> _onLoadQrConfigs(
    LoadQrConfigs event,
    Emitter<QrLinkState> emit,
  ) async {
    emit(QrLinkLoading());
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) {
        emit(const QrLinkError('User not authenticated'));
        return;
      }

      final configs = await _localStorageService.getAllQrConfigs(userId);
      emit(QrLinkLoaded([], qrConfigs: configs));
    } catch (e) {
      emit(QrLinkError('Failed to load QR configs: $e'));
    }
  }

  Future<void> _onDeleteQrConfig(
    DeleteQrConfig event,
    Emitter<QrLinkState> emit,
  ) async {
    try {
      await _localStorageService.deleteQrConfig(event.configId);

      // Reload configs
      add(LoadQrConfigs());
    } catch (e) {
      emit(QrLinkError('Failed to delete QR config: $e'));
    }
  }

  String _generateRandomSlug() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    // Generate a longer slug to reduce collision probability
    return List.generate(
      8, // Increased from 8 to reduce collisions
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  // Generate a truly unique slug with timestamp
  String _generateUniqueSlug() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(8); // Last 5 digits

    final randomPart =
        List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();

    return randomPart + timestamp;
  }
}
