import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}

class AuthSignInWithGoogleRequested extends AuthEvent {}

class AuthSignInWithPhoneRequested extends AuthEvent {
  final String phoneNumber;

  const AuthSignInWithPhoneRequested(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class AuthVerifyPhoneCodeRequested extends AuthEvent {
  final String verificationId;
  final String smsCode;

  const AuthVerifyPhoneCodeRequested(this.verificationId, this.smsCode);

  @override
  List<Object> get props => [verificationId, smsCode];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final String? userId;

  const AuthUserChanged(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AuthPrivacySetupCompleted extends AuthEvent {
  final bool isDiscoverable;

  const AuthPrivacySetupCompleted(this.isDiscoverable);

  @override
  List<Object> get props => [isDiscoverable];
}
