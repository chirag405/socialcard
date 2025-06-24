import 'package:equatable/equatable.dart';
import '../../models/user_profile.dart';
import '../../models/saved_contact.dart';

abstract class ScanState extends Equatable {
  const ScanState();

  @override
  List<Object?> get props => [];
}

class ScanInitial extends ScanState {}

class ScanActive extends ScanState {}

class ScanInactive extends ScanState {}

class ScanProcessing extends ScanState {
  final String qrResult;

  const ScanProcessing(this.qrResult);

  @override
  List<Object> get props => [qrResult];
}

class ScanProcessed extends ScanState {
  final UserProfile profile;
  final String originalQrResult;

  const ScanProcessed({required this.profile, required this.originalQrResult});

  @override
  List<Object> get props => [profile, originalQrResult];
}

class ScanInvalidQr extends ScanState {
  final String qrResult;
  final String error;

  const ScanInvalidQr({required this.qrResult, required this.error});

  @override
  List<Object> get props => [qrResult, error];
}

class ScanContactSaving extends ScanState {
  final UserProfile profile;

  const ScanContactSaving(this.profile);

  @override
  List<Object> get props => [profile];
}

class ScanContactSaved extends ScanState {
  final SavedContact savedContact;

  const ScanContactSaved(this.savedContact);

  @override
  List<Object> get props => [savedContact];
}

class ScanHistoryLoading extends ScanState {}

class ScanHistoryLoaded extends ScanState {
  final List<SavedContact> history;

  const ScanHistoryLoaded(this.history);

  @override
  List<Object> get props => [history];

  ScanHistoryLoaded copyWith({List<SavedContact>? history}) {
    return ScanHistoryLoaded(history ?? this.history);
  }
}

class ScanHistoryDeleting extends ScanState {
  final String profileId;
  final List<SavedContact> currentHistory;

  const ScanHistoryDeleting({
    required this.profileId,
    required this.currentHistory,
  });

  @override
  List<Object> get props => [profileId, currentHistory];
}

class ScanHistoryDeleted extends ScanState {
  final String profileId;
  final List<SavedContact> updatedHistory;

  const ScanHistoryDeleted({
    required this.profileId,
    required this.updatedHistory,
  });

  @override
  List<Object> get props => [profileId, updatedHistory];
}

class ScanHistoryClearing extends ScanState {}

class ScanHistoryCleared extends ScanState {}

class ScanError extends ScanState {
  final String message;
  final String? qrResult;

  const ScanError({required this.message, this.qrResult});

  @override
  List<Object?> get props => [message, qrResult];
}
