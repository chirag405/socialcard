import 'package:equatable/equatable.dart';
import '../../models/user_profile.dart';

abstract class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object?> get props => [];
}

class ScanStarted extends ScanEvent {}

class ScanStopped extends ScanEvent {}

class ScanProcessResult extends ScanEvent {
  final String qrResult;

  const ScanProcessResult(this.qrResult);

  @override
  List<Object> get props => [qrResult];
}

class ScanSaveContact extends ScanEvent {
  final UserProfile profile;
  final String? notes;

  const ScanSaveContact({required this.profile, this.notes});

  @override
  List<Object?> get props => [profile, notes];
}

class ScanLoadHistory extends ScanEvent {}

class ScanDeleteFromHistory extends ScanEvent {
  final String profileId;

  const ScanDeleteFromHistory(this.profileId);

  @override
  List<Object> get props => [profileId];
}

class ScanClearHistory extends ScanEvent {}

class ScanRetry extends ScanEvent {
  final String qrResult;

  const ScanRetry(this.qrResult);

  @override
  List<Object> get props => [qrResult];
}
