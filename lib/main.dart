import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'services/supabase_service.dart';
import 'services/local_storage_service.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/profile/profile_bloc.dart';
import 'blocs/qr_link/qr_link_bloc.dart';
import 'blocs/preset/preset_bloc.dart';
import 'blocs/scan/scan_bloc.dart';
import 'blocs/contacts/contacts_bloc.dart';
import 'services/contacts_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/privacy_prompt_screen.dart';
import 'screens/home/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase
    await SupabaseService.initialize();
  } catch (e) {
    print('Supabase initialization failed: $e');
    // Continue anyway, the app can still work with limited functionality
  }

  // Initialize local storage (platform-aware)
  // On mobile: SQLite database, On web: SharedPreferences
  if (!kIsWeb) {
    try {
      await LocalStorageService().database;
    } catch (e) {
      print('Database initialization failed: $e');
      // Continue anyway, the app can still work with SharedPreferences fallback
    }
  }

  runApp(const SocialCardApp());
}

class SocialCardApp extends StatelessWidget {
  const SocialCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SupabaseService>(
          create: (context) => SupabaseService(),
        ),
        RepositoryProvider<LocalStorageService>(
          create: (context) => LocalStorageService(),
        ),
        RepositoryProvider<ContactsService>(
          create: (context) => ContactsService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create:
                (context) =>
                    AuthBloc(supabaseService: context.read<SupabaseService>())
                      ..add(AuthStarted()),
          ),
          BlocProvider<ProfileBloc>(
            create:
                (context) => ProfileBloc(
                  supabaseService: context.read<SupabaseService>(),
                ),
          ),
          BlocProvider<QrLinkBloc>(
            create:
                (context) => QrLinkBloc(
                  supabaseService: context.read<SupabaseService>(),
                  localStorageService: context.read<LocalStorageService>(),
                ),
          ),
          BlocProvider<PresetBloc>(
            create:
                (context) => PresetBloc(
                  supabaseService: context.read<SupabaseService>(),
                  localStorageService: context.read<LocalStorageService>(),
                ),
          ),
          BlocProvider<ScanBloc>(
            create:
                (context) => ScanBloc(
                  supabaseService: context.read<SupabaseService>(),
                  contactsService: context.read<ContactsService>(),
                  localStorageService: context.read<LocalStorageService>(),
                ),
          ),
          BlocProvider<ContactsBloc>(
            create:
                (context) => ContactsBloc(
                  supabaseService: context.read<SupabaseService>(),
                  contactsService: context.read<ContactsService>(),
                  localStorageService: context.read<LocalStorageService>(),
                ),
          ),
        ],
        child: MaterialApp(
          title: 'SocialCard Pro',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const AppNavigator(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const SplashScreen();
        } else if (state is AuthNewUserPrivacyPrompt) {
          return const PrivacyPromptScreen();
        } else if (state is AuthAuthenticated) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
