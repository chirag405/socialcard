import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import 'phone_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is AuthPhoneVerificationSent) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => PhoneVerificationScreen(
                      verificationId: state.verificationId,
                      phoneNumber: state.phoneNumber,
                    ),
              ),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          const Spacer(),
                          _buildHeader(),
                          const SizedBox(height: 64),
                          _buildLoginOptions(context),
                          const Spacer(),
                          _buildFooter(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.qr_code_2_rounded,
            size: 48,
            color: Color(0xFF6366F1),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Welcome to',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white70,
            // fontFamily: 'Poppins',
          ),
        ),
        const Text(
          'SocialCard Pro',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            // fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Create and share your digital business card\nwith custom QR codes and links',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            // fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildLoginOptions(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        isLoading
                            ? null
                            : () => context.read<AuthBloc>().add(
                              AuthSignInWithGoogleRequested(),
                            ),
                    icon:
                        isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.login, size: 24),
                    label: Text(
                      isLoading ? 'Signing in...' : 'Continue with Google',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(height: 1, color: Colors.white30),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(height: 1, color: Colors.white30),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                        isLoading
                            ? null
                            : () => _showPhoneNumberDialog(context),
                    icon: const Icon(Icons.phone, color: Colors.white),
                    label: const Text(
                      'Continue with Phone',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'By continuing, you agree to our',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              child: const Text(
                'Terms of Service',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              ' and ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Privacy Policy',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPhoneNumberDialog(BuildContext context) {
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Enter Phone Number'),
            content: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '+1 234 567 8900',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final phoneNumber = phoneController.text.trim();
                  if (phoneNumber.isNotEmpty) {
                    Navigator.of(dialogContext).pop();
                    context.read<AuthBloc>().add(
                      AuthSignInWithPhoneRequested(phoneNumber),
                    );
                  }
                },
                child: const Text('Send Code'),
              ),
            ],
          ),
    );
  }
}
