import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../services/supabase_service.dart';
import 'auth_event.dart';
import 'auth_state.dart' as app_auth;

class AuthBloc extends Bloc<AuthEvent, app_auth.AuthState> {
  final SupabaseService _supabaseService;
  StreamSubscription<supabase.AuthState>? _authSubscription;

  AuthBloc({required SupabaseService supabaseService})
    : _supabaseService = supabaseService,
      super(app_auth.AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogle);
    on<AuthSignInWithPhoneRequested>(_onSignInWithPhone);
    on<AuthVerifyPhoneCodeRequested>(_onVerifyPhoneCode);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthPrivacySetupCompleted>(_onPrivacySetupCompleted);
  }

  void _onAuthStarted(AuthStarted event, Emitter<app_auth.AuthState> emit) {
    _authSubscription = supabase.Supabase.instance.client.auth.onAuthStateChange
        .listen((data) {
          final user = data.session?.user;
          add(AuthUserChanged(user?.id));
        });
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogleRequested event,
    Emitter<app_auth.AuthState> emit,
  ) async {
    emit(app_auth.AuthLoading());
    try {
      final response = await _supabaseService.signInWithGoogle();
      final user = _supabaseService.currentUser;
      if (user != null) {
        emit(app_auth.AuthAuthenticated(user.id));
      } else {
        emit(app_auth.AuthUnauthenticated());
      }
    } catch (e) {
      emit(app_auth.AuthError(e.toString()));
    }
  }

  Future<void> _onSignInWithPhone(
    AuthSignInWithPhoneRequested event,
    Emitter<app_auth.AuthState> emit,
  ) async {
    emit(app_auth.AuthLoading());
    try {
      await _supabaseService.signInWithPhoneNumber(event.phoneNumber);
      emit(
        app_auth.AuthPhoneVerificationSent(
          event.phoneNumber,
          event.phoneNumber,
        ),
      );
    } catch (e) {
      emit(app_auth.AuthError('Phone verification failed: $e'));
    }
  }

  Future<void> _onVerifyPhoneCode(
    AuthVerifyPhoneCodeRequested event,
    Emitter<app_auth.AuthState> emit,
  ) async {
    emit(app_auth.AuthLoading());
    try {
      final response = await _supabaseService.verifyPhoneOTP(
        event.verificationId, // This is the phone number for Supabase
        event.smsCode,
      );
      final user = response?.user;
      if (user != null) {
        emit(app_auth.AuthAuthenticated(user.id));
      } else {
        emit(app_auth.AuthError('Verification failed'));
      }
    } catch (e) {
      emit(app_auth.AuthError('Code verification failed: $e'));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<app_auth.AuthState> emit,
  ) async {
    try {
      await _supabaseService.signOut();
      emit(app_auth.AuthUnauthenticated());
    } catch (e) {
      emit(app_auth.AuthError('Sign out failed: $e'));
    }
  }

  Future<void> _onUserChanged(
    AuthUserChanged event,
    Emitter<app_auth.AuthState> emit,
  ) async {
    if (event.userId != null) {
      // Check if this is a new user who needs privacy setup
      final isNew = await _supabaseService.isNewUser(event.userId!);
      if (isNew) {
        emit(app_auth.AuthNewUserPrivacyPrompt(event.userId!));
      } else {
        emit(app_auth.AuthAuthenticated(event.userId!));
      }
    } else {
      emit(app_auth.AuthUnauthenticated());
    }
  }

  Future<void> _onPrivacySetupCompleted(
    AuthPrivacySetupCompleted event,
    Emitter<app_auth.AuthState> emit,
  ) async {
    try {
      final currentUser = _supabaseService.currentUser;
      if (currentUser != null) {
        // Create the user profile with the privacy setting
        await _supabaseService.createOrUpdateUserProfile(currentUser);

        // Update the privacy setting
        final userProfile = await _supabaseService.getUserProfile(
          currentUser.id,
        );
        if (userProfile != null) {
          final updatedProfile = userProfile.copyWith(
            isDiscoverable: event.isDiscoverable,
          );
          await _supabaseService.updateUserProfile(updatedProfile);
        }

        emit(app_auth.AuthAuthenticated(currentUser.id));
      }
    } catch (e) {
      emit(app_auth.AuthError('Failed to complete privacy setup: $e'));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
