import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const PhoneVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  String get _verificationCode {
    return _controllers.map((controller) => controller.text).join();
  }

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (_verificationCode.length == 6) {
      _verifyCode();
    }
  }

  void _verifyCode() {
    context.read<AuthBloc>().add(
      AuthVerifyPhoneCodeRequested(widget.verificationId, _verificationCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
            // Clear the input fields on error
            for (var controller in _controllers) {
              controller.clear();
            }
            _focusNodes[0].requestFocus();
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
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    const Spacer(),
                    _buildHeader(),
                    const SizedBox(height: 48),
                    _buildCodeInput(),
                    const SizedBox(height: 32),
                    _buildVerifyButton(),
                    const SizedBox(height: 24),
                    _buildResendButton(),
                    const Spacer(flex: 2),
                  ],
                ),
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
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.sms_outlined, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 24),
        const Text(
          'Verify Phone Number',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            // fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Enter the 6-digit code sent to\n${widget.phoneNumber}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
            // fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 45,
          height: 55,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white, width: 2),
              ),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => _onCodeChanged(index, value),
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                isLoading || _verificationCode.length != 6 ? null : _verifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child:
                isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text(
                      'Verify Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        );
      },
    );
  }

  Widget _buildResendButton() {
    return TextButton(
      onPressed: () {
        // TODO: Implement resend functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code resent!')),
        );
      },
      child: const Text(
        'Didn\'t receive the code? Resend',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
