import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/core/constants/auth_constants.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/utils/phone_utils.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';
import 'package:patch_bro/features/auth/presentation/widgets/login_from_card.dart';

import '../../../../core/widgets/auth_scaffold.dart';
import '../widgets/auth_bottom_prompt.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_header.dart';
import '../../../../core/widgets/app_primary_button.dart';
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
    if (ref.read(authControllerProvider).isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      final config = ref.read(appConfigProvider);

      await ref
          .read(authControllerProvider.notifier)
          .signIn(
            phone: normalizePhone(_phoneController.text),
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

      AppSnackbar.error(context, error.toString());
    }
  }

  Future<void> _signInWithGoogle() async {
    if (ref.read(authControllerProvider).isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      await ref
          .read(authControllerProvider.notifier)
          .signInWithGoogle(redirectTo: AuthConstants.googleRedirectUri);
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      authControllerProvider.select((state) => state.isLoading),
    );

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

              LoginFormCard(
                phoneController: _phoneController,
                passwordController: _passwordController,
                obscurePassword: _obscurePassword,
                onTogglePassword: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                onForgotPassword: () {
                  context.push('/forgot-password');
                },
              ),

              const SizedBox(height: 34),

              AppPrimaryButton(
                label: 'Sign in',
                isLoading: isLoading,
                onPressed: isLoading ? null : _login,
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
                      onPressed: isLoading
                          ? null
                          : () {
                              /// TODO: Apple Sign-In will be implemented later.
                            },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SocialLoginButton(
                      provider: SocialProvider.google,
                      label: 'Log in with Google',
                      onPressed: isLoading ? null : _signInWithGoogle,
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
