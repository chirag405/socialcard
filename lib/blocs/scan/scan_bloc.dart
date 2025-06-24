import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user_profile.dart';
import '../../models/saved_contact.dart';
import '../../services/supabase_service.dart';
import '../../services/contacts_service.dart';
import '../../services/local_storage_service.dart';
import 'scan_event.dart';
import 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final SupabaseService _supabaseService;
  final ContactsService _contactsService;
  final LocalStorageService _localStorageService;

  ScanBloc({
    required SupabaseService supabaseService,
    required ContactsService contactsService,
    required LocalStorageService localStorageService,
  }) : _supabaseService = supabaseService,
       _contactsService = contactsService,
       _localStorageService = localStorageService,
       super(ScanInitial()) {
    on<ScanStarted>(_onScanStarted);
    on<ScanStopped>(_onScanStopped);
    on<ScanProcessResult>(_onProcessResult);
    on<ScanSaveContact>(_onSaveContact);
    on<ScanLoadHistory>(_onLoadHistory);
    on<ScanDeleteFromHistory>(_onDeleteFromHistory);
    on<ScanClearHistory>(_onClearHistory);
    on<ScanRetry>(_onRetry);
  }

  void _onScanStarted(ScanStarted event, Emitter<ScanState> emit) {
    emit(ScanActive());
  }

  void _onScanStopped(ScanStopped event, Emitter<ScanState> emit) {
    emit(ScanInactive());
  }

  Future<void> _onProcessResult(
    ScanProcessResult event,
    Emitter<ScanState> emit,
  ) async {
    emit(ScanProcessing(event.qrResult));

    try {
      // Extract profile slug from QR result
      final profileSlug = _extractProfileSlug(event.qrResult);

      if (profileSlug == null) {
        // If not a SocialCard QR, try to open as URL
        if (await canLaunchUrl(Uri.parse(event.qrResult))) {
          await launchUrl(Uri.parse(event.qrResult));
          emit(ScanInactive());
        } else {
          emit(
            ScanInvalidQr(
              qrResult: event.qrResult,
              error: 'Invalid QR code format',
            ),
          );
        }
        return;
      }

      // Fetch the profile from the QR config
      final profile = await _fetchProfileFromSlug(profileSlug);

      if (profile != null) {
        emit(ScanProcessed(profile: profile, originalQrResult: event.qrResult));
      } else {
        emit(
          ScanInvalidQr(
            qrResult: event.qrResult,
            error: 'Profile not found or no longer available',
          ),
        );
      }
    } catch (e) {
      emit(
        ScanError(
          message: 'Failed to process QR code: $e',
          qrResult: event.qrResult,
        ),
      );
    }
  }

  Future<void> _onSaveContact(
    ScanSaveContact event,
    Emitter<ScanState> emit,
  ) async {
    try {
      emit(ScanContactSaving(event.profile));

      final currentUserId = _supabaseService.currentUserId;
      if (currentUserId == null) {
        emit(const ScanError(message: 'User not authenticated'));
        return;
      }

      // Don't save your own profile
      if (currentUserId == event.profile.id) {
        emit(const ScanError(message: 'Cannot save your own profile'));
        return;
      }

      // Check if contact is already saved
      final isAlreadySaved = await _contactsService.isContactSaved(
        event.profile.id,
      );

      if (isAlreadySaved) {
        emit(const ScanError(message: 'Contact is already saved'));
        return;
      }

      // Save contact
      await _contactsService.saveScannedContact(
        event.profile.id,
        notes: event.notes,
      );

      // Create SavedContact object for the state
      final savedContact = SavedContact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        profile: event.profile,
        scannedAt: DateTime.now(),
        notes: event.notes,
      );

      emit(ScanContactSaved(savedContact));

      // Auto-load history to refresh
      add(ScanLoadHistory());
    } catch (e) {
      emit(ScanError(message: 'Failed to save contact: $e'));
    }
  }

  Future<void> _onLoadHistory(
    ScanLoadHistory event,
    Emitter<ScanState> emit,
  ) async {
    emit(ScanHistoryLoading());
    try {
      final history = await _localStorageService.getAllSavedContacts();
      emit(ScanHistoryLoaded(history));
    } catch (e) {
      emit(ScanError(message: 'Failed to load scan history: $e'));
    }
  }

  Future<void> _onDeleteFromHistory(
    ScanDeleteFromHistory event,
    Emitter<ScanState> emit,
  ) async {
    try {
      if (state is ScanHistoryLoaded) {
        final currentHistory = (state as ScanHistoryLoaded).history;
        emit(
          ScanHistoryDeleting(
            profileId: event.profileId,
            currentHistory: currentHistory,
          ),
        );

        await _contactsService.deleteSavedContact(event.profileId);

        final updatedHistory =
            currentHistory
                .where((contact) => contact.profile.id != event.profileId)
                .toList();

        emit(
          ScanHistoryDeleted(
            profileId: event.profileId,
            updatedHistory: updatedHistory,
          ),
        );

        // Update to loaded state with new history
        emit(ScanHistoryLoaded(updatedHistory));
      }
    } catch (e) {
      emit(ScanError(message: 'Failed to delete from history: $e'));
    }
  }

  Future<void> _onClearHistory(
    ScanClearHistory event,
    Emitter<ScanState> emit,
  ) async {
    try {
      emit(ScanHistoryClearing());

      // Delete all saved contacts
      final allContacts = await _localStorageService.getAllSavedContacts();
      for (final contact in allContacts) {
        await _contactsService.deleteSavedContact(contact.profile.id);
      }

      emit(ScanHistoryCleared());
      emit(const ScanHistoryLoaded([]));
    } catch (e) {
      emit(ScanError(message: 'Failed to clear history: $e'));
    }
  }

  Future<void> _onRetry(ScanRetry event, Emitter<ScanState> emit) async {
    // Retry processing the same QR result
    add(ScanProcessResult(event.qrResult));
  }

  // Helper methods extracted from scanner_screen.dart
  String? _extractProfileSlug(String qrResult) {
    // Handle different QR formats:
    // 1. Direct slug: "chirag"
    // 2. Full URL: "https://domain.com/profile?slug=chirag"
    // 3. Short URL: "https://domain.com/chirag"

    if (qrResult.contains('http')) {
      final uri = Uri.tryParse(qrResult);
      if (uri != null) {
        // Check for slug parameter
        if (uri.queryParameters.containsKey('slug')) {
          return uri.queryParameters['slug'];
        }
        // Check for slug in path
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          return pathSegments.last;
        }
      }
    } else {
      // Direct slug
      return qrResult.trim();
    }

    return null;
  }

  Future<UserProfile?> _fetchProfileFromSlug(String slug) async {
    try {
      // Get QR config by slug
      final qrConfig = await _supabaseService.getQrConfigBySlug(slug);
      if (qrConfig == null) return null;

      // Check if expired
      if (qrConfig.isExpired) return null;

      // Get user profile
      final profile = await _supabaseService.getUserProfile(qrConfig.userId);
      return profile;
    } catch (e) {
      // TODO: Use proper logging instead of print
      // ignore: avoid_print
      print('Error fetching profile: $e');
      return null;
    }
  }
}
