import 'package:equatable/equatable.dart';
import '../../models/user_profile.dart';
import '../../models/saved_contact.dart';

abstract class ContactsEvent extends Equatable {
  const ContactsEvent();

  @override
  List<Object?> get props => [];
}

class ContactsLoadRequested extends ContactsEvent {}

class ContactsImportPhoneRequested extends ContactsEvent {}

class ContactsDiscoveryRequested extends ContactsEvent {}

class ContactsSearchRequested extends ContactsEvent {
  final String query;

  const ContactsSearchRequested(this.query);

  @override
  List<Object> get props => [query];
}

class ContactsClearSearch extends ContactsEvent {}

class ContactsSaveRequested extends ContactsEvent {
  final UserProfile profile;
  final String? notes;

  const ContactsSaveRequested({required this.profile, this.notes});

  @override
  List<Object?> get props => [profile, notes];
}

class ContactsDeleteRequested extends ContactsEvent {
  final String profileId;

  const ContactsDeleteRequested(this.profileId);

  @override
  List<Object> get props => [profileId];
}

class ContactsUpdateRequested extends ContactsEvent {
  final SavedContact contact;

  const ContactsUpdateRequested(this.contact);

  @override
  List<Object> get props => [contact];
}

class ContactsMarkAsUpdatedRequested extends ContactsEvent {
  final String profileId;
  final bool hasUpdates;

  const ContactsMarkAsUpdatedRequested({
    required this.profileId,
    required this.hasUpdates,
  });

  @override
  List<Object> get props => [profileId, hasUpdates];
}

class ContactsRefreshProfileRequested extends ContactsEvent {
  final String profileId;

  const ContactsRefreshProfileRequested(this.profileId);

  @override
  List<Object> get props => [profileId];
}

class ContactsInviteNonUserRequested extends ContactsEvent {
  final String phoneNumber;
  final String? name;

  const ContactsInviteNonUserRequested({required this.phoneNumber, this.name});

  @override
  List<Object?> get props => [phoneNumber, name];
}

class ContactsPermissionRequested extends ContactsEvent {}

class ContactsSortChanged extends ContactsEvent {
  final ContactsSortType sortType;

  const ContactsSortChanged(this.sortType);

  @override
  List<Object> get props => [sortType];
}

enum ContactsSortType { name, dateAdded, lastInteraction }

class ContactsFilterChanged extends ContactsEvent {
  final ContactsFilterType filterType;

  const ContactsFilterChanged(this.filterType);

  @override
  List<Object> get props => [filterType];
}

enum ContactsFilterType { all, phoneContacts, scannedContacts, hasUpdates }
