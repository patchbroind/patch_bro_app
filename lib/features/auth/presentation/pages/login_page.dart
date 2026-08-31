import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/core/validators/validators.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';

import '../../../../core/widgets/auth_scaffold.dart';
import '../widgets/auth_bottom_prompt.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      final config = ref.read(appConfigProvider);

      await ref.read(authControllerProvider.notifier).signIn(
            phone: _normalizePhone(_phoneController.text),
            password: _passwordController.text,
          );

      if (!mounted) {
        return;
      }

      if (config.isWorker) {
        context.go('/worker/home');
      } else {
        context.go('/employer/home');
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    }
  }

  String _normalizePhone(String value) {
    final phone = value.trim();

    if (phone.startsWith('+')) {
      return phone;
    }

    return '+91$phone';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
          child: Column(
            children: [
              const AuthHeader(
                title: 'Hi!',
                subtitle: 'Login up to continue',
                imageAsset: 'assets/images/login_image.png',
                imageWidth: 170,
              ),

              const SizedBox(height: 55),

              _LoginFormCard(
                phoneController: _phoneController,
                passwordController: _passwordController,
                obscurePassword: _obscurePassword,
                onTogglePassword: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                onForgotPassword: () {
                  // Password recovery will be implemented later.
                },
              ),

              const SizedBox(height: 34),

              AuthPrimaryButton(
                label: 'Sign in',
                isLoading: authState.isLoading,
                onPressed: _login,
              ),

              const SizedBox(height: 28),

              const AuthDivider(),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: SocialLoginButton(
                      provider: SocialProvider.apple,
                      label: 'Log in with Apple',
                      onPressed: () {
                        // Apple Sign-In will be implemented later.
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SocialLoginButton(
                      provider: SocialProvider.google,
                      label: 'Log in with Google',
                      onPressed: () {
                        // Google Sign-In will be implemented later.
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              AuthBottomPrompt(
                message: "Don't have account? ",
                actionText: 'Sign up',
                onAction: () {
                  context.push('/signup');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginFormCard extends StatelessWidget {
  const _LoginFormCard({
    required this.phoneController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onForgotPassword,
  });

  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            spreadRadius: 2,
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: Column(
        children: [
          AuthTextField(
            controller: phoneController,
            hintText: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: Validators.password,
          ),
          const SizedBox(height: 18),
          AuthTextField(
            controller: passwordController,
            hintText: 'Password',
            icon: Icons.lock_outline,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            validator: Validators.password,
            suffixIcon: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.black54,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
              child: const Text(
                'Forget password',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}