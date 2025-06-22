import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;

  const AuthAuthenticated(this.userId);

  @override
  List<Object> get props => [userId];
}

class AuthUnauthenticated extends AuthState {}

class AuthPhoneVerificationSent extends AuthState {
  final String verificationId;
  final String phoneNumber;

  const AuthPhoneVerificationSent(this.verificationId, this.phoneNumber);

  @override
  List<Object> get props => [verificationId, phoneNumber];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class AuthNewUserPrivacyPrompt extends AuthState {
  final String userId;

  const AuthNewUserPrivacyPrompt(this.userId);

  @override
  List<Object> get props => [userId];
}
