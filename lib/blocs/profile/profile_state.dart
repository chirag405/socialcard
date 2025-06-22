import 'package:equatable/equatable.dart';
import '../../models/user_profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}

class ProfileUpdating extends ProfileState {
  final UserProfile profile;

  const ProfileUpdating(this.profile);

  @override
  List<Object> get props => [profile];
}

class ProfileUpdated extends ProfileState {
  final UserProfile profile;

  const ProfileUpdated(this.profile);

  @override
  List<Object> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;
  final UserProfile? profile;

  const ProfileError(this.message, {this.profile});

  @override
  List<Object?> get props => [message, profile];
}
