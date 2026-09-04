import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/utils/phone_utils.dart';
import 'package:patch_bro/core/validators/validators.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';
import 'package:patch_bro/core/widgets/app_text_field.dart';
import 'package:patch_bro/core/widgets/auth_scaffold.dart';
import 'package:patch_bro/features/auth/presentation/models/otp_verification_args.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (ref.read(authControllerProvider).isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phone = normalizePhone(_phoneController.text);

    FocusScope.of(context).unfocus();

    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendPasswordResetOtp(phone: phone);

      if (!mounted) {
        return;
      }

      context.push(
        '/otp',
        extra: OtpVerificationArgs.passwordReset(phone: phone),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(
        context,
        'Unable to send OTP. Please check your phone number and try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      authControllerProvider.select((state) => state.isLoading),
    );

    return AuthScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              const Icon(Icons.lock_reset_rounded, size: 72),

              const SizedBox(height: 24),

              Text(
                'Reset your password',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Enter the mobile number linked to your account. '
                'We will send you a verification code.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 32),

              AppTextField(
                controller: _phoneController,
                hintText: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.telephoneNumber],
                validator: Validators.phone,
                onFieldSubmitted: (_) {
                  if (!isLoading) {
                    _sendOtp();
                  }
                },
              ),

              const SizedBox(height: 24),

              AppPrimaryButton(
                label: 'Send OTP',
                isLoading: isLoading,
                onPressed: isLoading ? null : _sendOtp,
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        context.pop();
                      },
                child: const Text('Back to login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
