import 'package:equatable/equatable.dart';
import '../../models/user_profile.dart';
import '../../models/saved_contact.dart';
import 'contacts_event.dart';

abstract class ContactsState extends Equatable {
  const ContactsState();

  @override
  List<Object?> get props => [];
}

class ContactsInitial extends ContactsState {}

class ContactsLoading extends ContactsState {}

class ContactsPermissionRequired extends ContactsState {}

class ContactsPermissionDenied extends ContactsState {}

class ContactsLoaded extends ContactsState {
  final List<UserProfile> phoneContacts;
  final List<SavedContact> scannedContacts;
  final List<UserProfile> supabaseContacts;
  final String searchQuery;
  final ContactsSortType sortType;
  final ContactsFilterType filterType;
  final bool hasContactsPermission;

  const ContactsLoaded({
    required this.phoneContacts,
    required this.scannedContacts,
    required this.supabaseContacts,
    this.searchQuery = '',
    this.sortType = ContactsSortType.name,
    this.filterType = ContactsFilterType.all,
    this.hasContactsPermission = false,
  });

  @override
  List<Object?> get props => [
    phoneContacts,
    scannedContacts,
    supabaseContacts,
    searchQuery,
    sortType,
    filterType,
    hasContactsPermission,
  ];

  ContactsLoaded copyWith({
    List<UserProfile>? phoneContacts,
    List<SavedContact>? scannedContacts,
    List<UserProfile>? supabaseContacts,
    String? searchQuery,
    ContactsSortType? sortType,
    ContactsFilterType? filterType,
    bool? hasContactsPermission,
  }) {
    return ContactsLoaded(
      phoneContacts: phoneContacts ?? this.phoneContacts,
      scannedContacts: scannedContacts ?? this.scannedContacts,
      supabaseContacts: supabaseContacts ?? this.supabaseContacts,
      searchQuery: searchQuery ?? this.searchQuery,
      sortType: sortType ?? this.sortType,
      filterType: filterType ?? this.filterType,
      hasContactsPermission:
          hasContactsPermission ?? this.hasContactsPermission,
    );
  }

  // Get filtered and sorted contacts based on current settings
  List<dynamic> get filteredContacts {
    List<dynamic> allContacts = [];

    // Apply filter
    switch (filterType) {
      case ContactsFilterType.all:
        allContacts.addAll(phoneContacts);
        allContacts.addAll(scannedContacts);
        allContacts.addAll(supabaseContacts);
        break;
      case ContactsFilterType.phoneContacts:
        allContacts.addAll(phoneContacts);
        break;
      case ContactsFilterType.scannedContacts:
        allContacts.addAll(scannedContacts);
        break;
      case ContactsFilterType.hasUpdates:
        allContacts.addAll(
          scannedContacts.where((contact) => contact.hasUpdates),
        );
        break;
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      allContacts =
          allContacts.where((contact) {
            if (contact is UserProfile) {
              return contact.name.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  contact.email.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  (contact.phone?.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ??
                      false);
            } else if (contact is SavedContact) {
              final profile = contact.profile;
              return profile.name.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  profile.email.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  (profile.phone?.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ??
                      false);
            }
            return false;
          }).toList();
    }

    // Apply sorting
    switch (sortType) {
      case ContactsSortType.name:
        allContacts.sort((a, b) {
          final nameA =
              a is UserProfile ? a.name : (a as SavedContact).profile.name;
          final nameB =
              b is UserProfile ? b.name : (b as SavedContact).profile.name;
          return nameA.compareTo(nameB);
        });
        break;
      case ContactsSortType.dateAdded:
        allContacts.sort((a, b) {
          final dateA =
              a is UserProfile ? a.createdAt : (a as SavedContact).scannedAt;
          final dateB =
              b is UserProfile ? b.createdAt : (b as SavedContact).scannedAt;
          return dateB.compareTo(dateA); // Most recent first
        });
        break;
      case ContactsSortType.lastInteraction:
        allContacts.sort((a, b) {
          DateTime dateA;
          DateTime dateB;

          if (a is UserProfile) {
            dateA = a.updatedAt;
          } else {
            final savedContactA = a as SavedContact;
            dateA = savedContactA.lastUpdated ?? savedContactA.scannedAt;
          }

          if (b is UserProfile) {
            dateB = b.updatedAt;
          } else {
            final savedContactB = b as SavedContact;
            dateB = savedContactB.lastUpdated ?? savedContactB.scannedAt;
          }

          return dateB.compareTo(dateA); // Most recent first
        });
        break;
    }

    return allContacts;
  }

  int get totalContactsCount =>
      phoneContacts.length + scannedContacts.length + supabaseContacts.length;
  int get updatedContactsCount =>
      scannedContacts.where((c) => c.hasUpdates).length;
}

class ContactsImporting extends ContactsState {}

class ContactsImported extends ContactsState {
  final List<UserProfile> importedContacts;

  const ContactsImported(this.importedContacts);

  @override
  List<Object> get props => [importedContacts];
}

class ContactsDiscovering extends ContactsState {}

class ContactsDiscovered extends ContactsState {
  final List<UserProfile> discoveredContacts;

  const ContactsDiscovered(this.discoveredContacts);

  @override
  List<Object> get props => [discoveredContacts];
}

class ContactsSaving extends ContactsState {
  final UserProfile profile;

  const ContactsSaving(this.profile);

  @override
  List<Object> get props => [profile];
}

class ContactsSaved extends ContactsState {
  final SavedContact savedContact;

  const ContactsSaved(this.savedContact);

  @override
  List<Object> get props => [savedContact];
}

class ContactsDeleting extends ContactsState {
  final String profileId;

  const ContactsDeleting(this.profileId);

  @override
  List<Object> get props => [profileId];
}

class ContactsDeleted extends ContactsState {
  final String profileId;

  const ContactsDeleted(this.profileId);

  @override
  List<Object> get props => [profileId];
}

class ContactsUpdating extends ContactsState {
  final SavedContact contact;

  const ContactsUpdating(this.contact);

  @override
  List<Object> get props => [contact];
}

class ContactsUpdated extends ContactsState {
  final SavedContact contact;

  const ContactsUpdated(this.contact);

  @override
  List<Object> get props => [contact];
}

class ContactsRefreshing extends ContactsState {
  final String profileId;

  const ContactsRefreshing(this.profileId);

  @override
  List<Object> get props => [profileId];
}

class ContactsRefreshed extends ContactsState {
  final UserProfile refreshedProfile;

  const ContactsRefreshed(this.refreshedProfile);

  @override
  List<Object> get props => [refreshedProfile];
}

class ContactsInviting extends ContactsState {
  final String phoneNumber;

  const ContactsInviting(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class ContactsInvited extends ContactsState {
  final String phoneNumber;

  const ContactsInvited(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class ContactsError extends ContactsState {
  final String message;
  final ContactsState? previousState;

  const ContactsError(this.message, {this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}
