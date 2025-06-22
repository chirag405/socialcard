import 'package:equatable/equatable.dart';
import 'user_profile.dart';

class SavedContact extends Equatable {
  final String id;
  final UserProfile profile;
  final DateTime scannedAt;
  final DateTime? lastUpdated;
  final bool hasUpdates;
  final String? notes;

  const SavedContact({
    required this.id,
    required this.profile,
    required this.scannedAt,
    this.lastUpdated,
    this.hasUpdates = false,
    this.notes,
  });

  SavedContact copyWith({
    String? id,
    UserProfile? profile,
    DateTime? scannedAt,
    DateTime? lastUpdated,
    bool? hasUpdates,
    String? notes,
  }) {
    return SavedContact(
      id: id ?? this.id,
      profile: profile ?? this.profile,
      scannedAt: scannedAt ?? this.scannedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      hasUpdates: hasUpdates ?? this.hasUpdates,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile': profile.toMap(),
      'scannedAt': scannedAt.millisecondsSinceEpoch,
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
      'hasUpdates': hasUpdates,
      'notes': notes,
    };
  }

  factory SavedContact.fromMap(Map<String, dynamic> map) {
    return SavedContact(
      id: map['id'] ?? '',
      profile: UserProfile.fromMap(map['profile'] ?? {}),
      scannedAt: DateTime.fromMillisecondsSinceEpoch(map['scannedAt'] ?? 0),
      lastUpdated:
          map['lastUpdated'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'])
              : null,
      hasUpdates: map['hasUpdates'] ?? false,
      notes: map['notes'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    profile,
    scannedAt,
    lastUpdated,
    hasUpdates,
    notes,
  ];
}
