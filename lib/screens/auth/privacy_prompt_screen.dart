import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../services/contacts_service.dart';

class PrivacyPromptScreen extends StatefulWidget {
  const PrivacyPromptScreen({super.key});

  @override
  State<PrivacyPromptScreen> createState() => _PrivacyPromptScreenState();
}

class _PrivacyPromptScreenState extends State<PrivacyPromptScreen> {
  bool _isProcessing = false;

  Future<void> _handleAcceptPrivacy() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Request contacts permission with explanation
      await _requestContactsPermission();

      // Mark privacy as accepted (defaulting to discoverable)
      context.read<AuthBloc>().add(const AuthPrivacySetupCompleted(true));
    } catch (e) {
      // Continue even if contacts permission fails
      context.read<AuthBloc>().add(const AuthPrivacySetupCompleted(true));
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _requestContactsPermission() async {
    final contactsService = ContactsService();

    // Show explanation dialog first
    final shouldRequest = await _showContactsPermissionDialog();

    if (shouldRequest) {
      try {
        await contactsService.requestContactPermission();
      } catch (e) {
        print('Contacts permission request failed: $e');
        // Continue anyway - contacts permission is optional
      }
    }
  }

  Future<bool> _showContactsPermissionDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: const Text('Connect with Friends'),
                content: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SocialCard would like to access your contacts to help you find friends who are already using the app.',
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Features this enables:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• Find friends already on SocialCard'),
                    Text('• Get notified when contacts join'),
                    Text('• Easily share your profile with contacts'),
                    SizedBox(height: 16),
                    Text(
                      'Your contacts are never stored on our servers and are only used locally on your device.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Skip'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Allow Access'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo or Icon
              Icon(
                Icons.security,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Welcome to SocialCard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Privacy explanation
              Text(
                'Before you start, we need to let you know how we handle your data:',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Privacy points
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPrivacyPoint(
                      Icons.lock,
                      'Your Data is Secure',
                      'All your personal information is encrypted and stored securely.',
                    ),
                    const SizedBox(height: 16),
                    _buildPrivacyPoint(
                      Icons.visibility_off,
                      'Privacy by Default',
                      'You control what information is visible to others.',
                    ),
                    const SizedBox(height: 16),
                    _buildPrivacyPoint(
                      Icons.contacts,
                      'Contacts Stay Private',
                      'Your contacts are only used locally and never uploaded to our servers.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Accept button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handleAcceptPrivacy,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isProcessing
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Continue'),
                ),
              ),
              const SizedBox(height: 16),

              // Terms and privacy policy
              Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPoint(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
