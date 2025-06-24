import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/user_profile.dart';
import '../../models/saved_contact.dart';
import '../../services/supabase_service.dart';
import '../../services/contacts_service.dart';
import '../../services/local_storage_service.dart';
import '../../utils/app_config.dart';
import 'contacts_event.dart';
import 'contacts_state.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final SupabaseService _supabaseService;
  final ContactsService _contactsService;
  final LocalStorageService _localStorageService;

  ContactsBloc({
    required SupabaseService supabaseService,
    required ContactsService contactsService,
    required LocalStorageService localStorageService,
  }) : _supabaseService = supabaseService,
       _contactsService = contactsService,
       _localStorageService = localStorageService,
       super(ContactsInitial()) {
    on<ContactsLoadRequested>(_onLoadRequested);
    on<ContactsImportPhoneRequested>(_onImportPhoneRequested);
    on<ContactsDiscoveryRequested>(_onDiscoveryRequested);
    on<ContactsSearchRequested>(_onSearchRequested);
    on<ContactsClearSearch>(_onClearSearch);
    on<ContactsSaveRequested>(_onSaveRequested);
    on<ContactsDeleteRequested>(_onDeleteRequested);
    on<ContactsUpdateRequested>(_onUpdateRequested);
    on<ContactsMarkAsUpdatedRequested>(_onMarkAsUpdatedRequested);
    on<ContactsRefreshProfileRequested>(_onRefreshProfileRequested);
    on<ContactsInviteNonUserRequested>(_onInviteNonUserRequested);
    on<ContactsPermissionRequested>(_onPermissionRequested);
    on<ContactsSortChanged>(_onSortChanged);
    on<ContactsFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoadRequested(
    ContactsLoadRequested event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactsLoading());
    try {
      // Check contacts permission
      final hasPermission = await _contactsService.hasContactPermission();

      // Load all contact sources in parallel
      final futures = await Future.wait([
        _loadPhoneContacts(),
        _loadScannedContacts(),
        _loadSupabaseContacts(),
      ]);

      final phoneContacts = futures[0] as List<UserProfile>;
      final scannedContacts = futures[1] as List<SavedContact>;
      final supabaseContacts = futures[2] as List<UserProfile>;

      emit(
        ContactsLoaded(
          phoneContacts: phoneContacts,
          scannedContacts: scannedContacts,
          supabaseContacts: supabaseContacts,
          hasContactsPermission: hasPermission,
        ),
      );
    } catch (e) {
      emit(ContactsError('Failed to load contacts: $e'));
    }
  }

  Future<void> _onImportPhoneRequested(
    ContactsImportPhoneRequested event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactsImporting());
    try {
      final hasPermission = await _contactsService.hasContactPermission();
      if (!hasPermission) {
        emit(ContactsPermissionRequired());
        return;
      }

      final importedContacts = await _contactsService.getAppUsersFromContacts();
      emit(ContactsImported(importedContacts));

      // Reload all contacts
      add(ContactsLoadRequested());
    } catch (e) {
      emit(ContactsError('Failed to import phone contacts: $e'));
    }
  }

  Future<void> _onDiscoveryRequested(
    ContactsDiscoveryRequested event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactsDiscovering());
    try {
      final discoveredContacts =
          await _contactsService.getAppUsersFromContacts();
      emit(ContactsDiscovered(discoveredContacts));

      // Reload all contacts
      add(ContactsLoadRequested());
    } catch (e) {
      emit(ContactsError('Failed to discover contacts: $e'));
    }
  }

  Future<void> _onSearchRequested(
    ContactsSearchRequested event,
    Emitter<ContactsState> emit,
  ) async {
    if (state is ContactsLoaded) {
      final currentState = state as ContactsLoaded;
      emit(currentState.copyWith(searchQuery: event.query));
    }
  }

  Future<void> _onClearSearch(
    ContactsClearSearch event,
    Emitter<ContactsState> emit,
  ) async {
    if (state is ContactsLoaded) {
      final currentState = state as ContactsLoaded;
      emit(currentState.copyWith(searchQuery: ''));
    }
  }

  Future<void> _onSaveRequested(
    ContactsSaveRequested event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactsSaving(event.profile));
    try {
      await _contactsService.saveScannedContact(
        event.profile.id,
        notes: event.notes,
      );

      final savedContact = SavedContact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        profile: event.profile,
        scannedAt: DateTime.now(),
        notes: event.notes,
      );

      emit(ContactsSaved(savedContact));

      // Reload contacts
      add(ContactsLoadRequested());
    } catch (e) {
      emit(ContactsError('Failed to save contact: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    ContactsDeleteRequested event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactsDeleting(event.profileId));
    try {
      await _contactsService.deleteSavedContact(event.profileId);
      emit(ContactsDeleted(event.profileId));

      // Reload contacts
      add(ContactsLoadRequested());
    } catch (e) {
      emit(ContactsError('Failed to delete contact: $e'));
    }
  }

  Future<void> _onUpdateRequested(
    ContactsUpdateRequested event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactsUpdating(event.contact));
    try {
      await _localStorageService.updateSavedContact(event.contact);
      emit(ContactsUpdated(event.contact));

      // Reload contacts
      add(ContactsLoadRequested());
    } catch (e) {
      emit(ContactsError('Failed to update contact: $e'));
    }
  }

  Future<void> _onMarkAsUpdatedRequested(
    ContactsMarkAsUpdatedRequested event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      await _localStorageService.markContactAsUpdated(
        event.profileId,
        event.hasUpdates,
      );

      // Reload contacts to reflect changes
      add(ContactsLoadRequested());
    } catch (e) {
      emit(ContactsError('Failed to mark contact as updated: $e'));
    }
  }

  Future<void> _onRefreshProfileRequested(
    ContactsRefreshProfileRequested event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactsRefreshing(event.profileId));
    try {
      final refreshedProfile = await _supabaseService.getUserProfile(
        event.profileId,
      );

      if (refreshedProfile != null) {
        emit(ContactsRefreshed(refreshedProfile));

        // Update the saved contact with fresh data
        final savedContact = SavedContact(
          id: event.profileId,
          profile: refreshedProfile,
          scannedAt: DateTime.now(),
          lastUpdated: DateTime.now(),
          hasUpdates: false,
        );

        await _localStorageService.updateSavedContact(savedContact);

        // Reload contacts
        add(ContactsLoadRequested());
      } else {
        emit(ContactsError('Profile not found'));
      }
    } catch (e) {
      emit(ContactsError('Failed to refresh profile: $e'));
    }
  }

  Future<void> _onInviteNonUserRequested(
    ContactsInviteNonUserRequested event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactsInviting(event.phoneNumber));
    try {
      // Create invitation message
      final inviteMessage = '''
Hey${event.name != null ? ' ${event.name}' : ''}! 

I'm using SocialCard Pro to share my contact info easily. 
Check it out: ${AppConfig.androidAppUrl}

It's a great way to share your social links and contact details with a QR code!
''';

      // Use share_plus to send invitation
      await Share.share(inviteMessage, subject: 'Join me on SocialCard Pro!');

      emit(ContactsInvited(event.phoneNumber));
    } catch (e) {
      emit(ContactsError('Failed to send invitation: $e'));
    }
  }

  Future<void> _onPermissionRequested(
    ContactsPermissionRequested event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      final granted = await _contactsService.requestContactPermission();
      if (granted) {
        // Reload contacts with permission
        add(ContactsLoadRequested());
      } else {
        emit(ContactsPermissionDenied());
      }
    } catch (e) {
      emit(ContactsError('Failed to request permission: $e'));
    }
  }

  Future<void> _onSortChanged(
    ContactsSortChanged event,
    Emitter<ContactsState> emit,
  ) async {
    if (state is ContactsLoaded) {
      final currentState = state as ContactsLoaded;
      emit(currentState.copyWith(sortType: event.sortType));
    }
  }

  Future<void> _onFilterChanged(
    ContactsFilterChanged event,
    Emitter<ContactsState> emit,
  ) async {
    if (state is ContactsLoaded) {
      final currentState = state as ContactsLoaded;
      emit(currentState.copyWith(filterType: event.filterType));
    }
  }

  // Helper methods
  Future<List<UserProfile>> _loadPhoneContacts() async {
    try {
      return await _contactsService.getAppUsersFromContacts();
    } catch (e) {
      // TODO: Use proper logging instead of print
      // ignore: avoid_print
      print('Error loading phone contacts: $e');
      return [];
    }
  }

  Future<List<SavedContact>> _loadScannedContacts() async {
    try {
      return await _localStorageService.getAllSavedContacts();
    } catch (e) {
      // TODO: Use proper logging instead of print
      // ignore: avoid_print
      print('Error loading scanned contacts: $e');
      return [];
    }
  }

  Future<List<UserProfile>> _loadSupabaseContacts() async {
    try {
      return await _contactsService.getSavedContacts();
    } catch (e) {
      // TODO: Use proper logging instead of print
      // ignore: avoid_print
      print('Error loading Supabase contacts: $e');
      return [];
    }
  }
}
