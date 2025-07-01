import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../services/supabase_service.dart';
import 'auth_event.dart';
import 'auth_state.dart' as app_auth;

// Platform-specific imports
import 'auth_web_helper.dart'
    if (dart.library.io) 'auth_mobile_helper.dart'
    as auth_helper;

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

  void _onAuthStarted(
    AuthStarted event,
    Emitter<app_auth.AuthState> emit,
  ) async {
    // Check for OAuth callback first
    if (kIsWeb) {
      await _handleOAuthCallback();
    }

    // Check if user is already authenticated on startup
    final currentUser = supabase.Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      print(
        '🔗 AuthBloc: User already authenticated on startup: ${currentUser.id}',
      );
      add(AuthUserChanged(currentUser.id));
    }

    // Listen for auth state changes
    _authSubscription = supabase.Supabase.instance.client.auth.onAuthStateChange
        .listen((data) {
          print(
            '🔗 AuthBloc: Auth state changed - Event: ${data.event}, Session: ${data.session != null}',
          );
          final user = data.session?.user;
          add(AuthUserChanged(user?.id));
        });
  }

  Future<void> _handleOAuthCallback() async {
    try {
      final currentUrl = auth_helper.AuthHelper.getCurrentUrl();
      if (currentUrl.isEmpty) return; // Skip on mobile platforms

      final uri = Uri.parse(currentUrl);
      print('🔗 AuthBloc: Current URL: ${uri.toString()}');

      // Check for authorization code in URL (PKCE flow)
      if (uri.queryParameters.containsKey('code')) {
        final code = uri.queryParameters['code'];
        final state = uri.queryParameters['state'];
        print(
          '🔗 AuthBloc: Found authorization code: ${code?.substring(0, 20)}...',
        );
        print('🔗 AuthBloc: Found state: $state');

        // Let Supabase handle the code exchange
        final response = await supabase.Supabase.instance.client.auth
            .getSessionFromUrl(uri);

        if (response.session != null) {
          print(
            '🔗 AuthBloc: OAuth session created successfully for user: ${response.session!.user.id}',
          );
        } else {
          print(
            '🔗 AuthBloc: Warning - OAuth callback processed but no session created',
          );
        }

        // Clean up the URL by removing the code parameter
        final cleanUrl = '${uri.origin}${uri.path}';
        auth_helper.AuthHelper.replaceUrl(cleanUrl);

        print('🔗 AuthBloc: OAuth callback handled, URL cleaned');
      } else if (uri.fragment.isNotEmpty &&
          uri.fragment.contains('access_token')) {
        // Handle implicit flow (access_token in hash)
        print(
          '🔗 AuthBloc: Found access_token in URL fragment (implicit flow)',
        );
        final response = await supabase.Supabase.instance.client.auth
            .getSessionFromUrl(uri);

        if (response.session != null) {
          print(
            '🔗 AuthBloc: Implicit flow session created successfully for user: ${response.session!.user.id}',
          );
        } else {
          print(
            '🔗 AuthBloc: Warning - Implicit flow processed but no session created',
          );
        }

        // Clean up the URL
        final cleanUrl = '${uri.origin}${uri.path}';
        auth_helper.AuthHelper.replaceUrl(cleanUrl);
      } else {
        print('🔗 AuthBloc: No OAuth parameters found in URL');
      }
    } catch (e) {
      print('🔗 AuthBloc: Error handling OAuth callback: $e');
      // Don't throw here as this might be called on every page load
    }
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogleRequested event,
    Emitter<app_auth.AuthState> emit,
  ) async {
    emit(app_auth.AuthLoading());
    try {
      await _supabaseService.signInWithGoogle();
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
    try {
      if (event.userId != null) {
        print('🔗 AuthBloc: User changed to: ${event.userId}');

        // Check if this is a new user who needs privacy setup
        final isNew = await _supabaseService.isNewUser(event.userId!);
        print('🔗 AuthBloc: Is new user: $isNew');

        if (isNew) {
          print('🔗 AuthBloc: Emitting AuthNewUserPrivacyPrompt');
          emit(app_auth.AuthNewUserPrivacyPrompt(event.userId!));
        } else {
          print('🔗 AuthBloc: Emitting AuthAuthenticated');
          emit(app_auth.AuthAuthenticated(event.userId!));
        }
      } else {
        print('🔗 AuthBloc: User signed out, emitting AuthUnauthenticated');
        emit(app_auth.AuthUnauthenticated());
      }
    } catch (e) {
      print('🔗 AuthBloc: Error in _onUserChanged: $e');
      emit(app_auth.AuthError('Authentication error: $e'));
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
