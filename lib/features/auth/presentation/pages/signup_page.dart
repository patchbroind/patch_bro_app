import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/core/validators/validators.dart';

import '../../../../core/widgets/auth_scaffold.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_bottom_prompt.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_header.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../widgets/social_login_button.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      final phone = _normalizePhone(_phoneController.text);

      await ref
          .read(authControllerProvider.notifier)
          .signUp(
            phone: phone,
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) {
        return;
      }

      context.push('/otp', extra: phone);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
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
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
          child: Column(
            children: [
              const AuthHeader(
                title: 'Hello!',
                subtitle: 'Sign up to continue',
                imageAsset: 'assets/images/signup_image.png',
                imageWidth: 170,
              ),

              const SizedBox(height: 45),

              AppTextField(
                controller: _phoneController,
                hintText: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: Validators.phone,
              ),

              const SizedBox(height: 18),

              AppTextField(
                controller: _emailController,
                hintText: 'E-mail',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.email,
              ),

              const SizedBox(height: 18),

              AppTextField(
                controller: _passwordController,
                hintText: 'Password',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                validator: Validators.password,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              AppTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm Password',
                icon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  return Validators.confirmPassword(value, _passwordController.text);
                },
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              AppPrimaryButton(
                label: 'Sign Up',
                isLoading: authState.isLoading,
                onPressed: _signUp,
              ),

              const SizedBox(height: 28),

              const AuthDivider(label: 'or'),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: SocialLoginButton(
                      provider: SocialProvider.apple,
                      label: 'Sign up with Apple',
                      onPressed: () {
                        // Apple Sign-In will be implemented later.
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SocialLoginButton(
                      provider: SocialProvider.google,
                      label: 'Sign up with Google',
                      onPressed: () {
                        // Google Sign-In will be implemented later.
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              AuthBottomPrompt(
                message: 'Already member? ',
                actionText: 'Log in',
                onAction: () {
                  context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
