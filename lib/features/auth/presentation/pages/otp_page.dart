import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/features/auth/presentation/widgets/otp_resend_section.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/core/widgets/app_primary_button.dart';
import 'package:patch_bro/core/widgets/auth_scaffold.dart';
import 'package:patch_bro/features/auth/presentation/models/otp_verification_args.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';
import 'package:patch_bro/features/profile/presentation/providers/profile_providers.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({super.key, required this.request});

  final OtpVerificationArgs request;

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();

  bool _isResending = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _otpFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  String get _message {
    switch (widget.request.type) {
      case OtpVerificationType.passwordReset:
        return 'We have sent a password reset code\nto your mobile number.';

      case OtpVerificationType.phoneChange:
        return 'We have sent a verification code\nto your new mobile number.';

      case OtpVerificationType.signup:
        return 'We have sent a verification code\nto your mobile number.';
    }
  }

  Future<void> _verifyOtp() async {
    if (ref.read(authControllerProvider).isLoading || _isResending) {
      return;
    }

    final token = _otpController.text.trim();

    if (token.length != 6) {
      AppSnackbar.error(context, 'Please enter the 6-digit verification code.');
      return;
    }

    FocusScope.of(context).unfocus();

    final controller = ref.read(authControllerProvider.notifier);

    try {
      switch (widget.request.type) {
        case OtpVerificationType.passwordReset:
          await controller.verifyPasswordResetOtp(
            phone: widget.request.phone,
            token: token,
          );

          if (!mounted) {
            return;
          }

          context.go('/reset-password');
          return;

        case OtpVerificationType.phoneChange:
          await controller.verifyPhoneChangeOtp(
            phone: widget.request.phone,
            token: token,
          );

          if (!mounted) {
            return;
          }

          final profileData = widget.request.profileData;

          if (profileData == null) {
            AppSnackbar.error(
              context,
              'Profile information is missing. Please try again.',
            );
            return;
          }

          await ref
              .read(profileRepositoryProvider)
              .saveProfile(
                name: profileData.name,
                phone: profileData.phone,
                address1: profileData.address1,
                address2: profileData.address2,
                pinCode: profileData.pinCode,
                state: profileData.state,
                isWorker: profileData.isWorker,
              );

          if (!mounted) {
            return;
          }

          context.go(profileData.isWorker ? '/worker/home' : '/employer/home');
          return;

        case OtpVerificationType.signup:
          await controller.verifyOtp(phone: widget.request.phone, token: token);

          if (!mounted) {
            return;
          }

          context.go('/profile-details');
          return;
      }
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(context, error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(context, 'Unable to verify the OTP. Please try again.');
    }
  }

  Future<void> _resendOtp() async {
    if (_isResending || ref.read(authControllerProvider).isLoading) {
      return;
    }

    setState(() {
      _isResending = true;
    });

    final controller = ref.read(authControllerProvider.notifier);

    try {
      if (widget.request.type == OtpVerificationType.passwordReset) {
        await controller.sendPasswordResetOtp(phone: widget.request.phone);
      } else {
        await controller.resendOtp(phone: widget.request.phone);
      }

      if (!mounted) {
        return;
      }

      _otpController.clear();

      AppSnackbar.success(context, 'A new OTP has been sent.');
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(context, error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(context, 'Unable to resend OTP. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authIsLoading = ref.watch(
      authControllerProvider.select((state) => state.isLoading),
    );
    final isLoading = authIsLoading || _isResending;

    return AuthScaffold(
      appBar: AppBar(title: const Text('Verification')),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Text(
              'Verify your phone',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _otpController,
              focusNode: _otpFocusNode,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              textAlign: TextAlign.center,
              maxLength: 6,
              autofocus: true,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                counterText: '',
              ),
              onChanged: (value) {
                if (value.length == 6 && !isLoading) {
                  _verifyOtp();
                }
              },
              onSubmitted: (_) {
                if (!isLoading) {
                  _verifyOtp();
                }
              },
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: 'Verify',
              isLoading: isLoading,
              onPressed: isLoading ? null : _verifyOtp,
            ),
            const SizedBox(height: 24),
            OtpResendSection(onResend: _resendOtp, enabled: !isLoading),
          ],
        ),
      ),
    );
  }
}
