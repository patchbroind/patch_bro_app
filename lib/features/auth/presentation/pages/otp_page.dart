import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/features/auth/presentation/models/otp_verification_args.dart';
import 'package:patch_bro/features/auth/presentation/providers/auth_providers.dart';
import 'package:patch_bro/features/profile/presentation/providers/profile_providers.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({
    super.key,
    required this.request,
  });

  final OtpVerificationArgs request;

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();

  Timer? _timer;
  int _secondsRemaining = 59;

  @override
  void initState() {
    super.initState();

    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _otpFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _secondsRemaining = 59;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_secondsRemaining <= 1) {
          timer.cancel();

          setState(() {
            _secondsRemaining = 0;
          });

          return;
        }

        setState(() {
          _secondsRemaining--;
        });
      },
    );
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
    final token = _otpController.text.trim();

    if (token.length != 6) {
      AppSnackbar.error(
        context,
        'Please enter the 6-digit verification code.',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final controller =
        ref.read(authControllerProvider.notifier);

    try {
      switch (widget.request.type) {
        // ==========================================================
        // PASSWORD RESET
        // ==========================================================

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

        // ==========================================================
        // PHONE CHANGE
        // ==========================================================

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

          await ref.read(profileRepositoryProvider).saveProfile(
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

          context.go(
            profileData.isWorker
                ? '/worker/home'
                : '/employer/home',
          );
          return;

        // ==========================================================
        // SIGNUP
        // ==========================================================

        case OtpVerificationType.signup:
          await controller.verifyOtp(
            phone: widget.request.phone,
            token: token,
          );

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

      AppSnackbar.error(
        context,
        error.message,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(
        context,
        'Unable to verify the OTP. Please try again.',
      );
    }
  }

  Future<void> _resendOtp() async {
    if (_secondsRemaining > 0) {
      return;
    }

    final controller =
        ref.read(authControllerProvider.notifier);

    try {
      // ============================================================
      // PASSWORD RESET
      // ============================================================

      if (widget.request.type ==
          OtpVerificationType.passwordReset) {
        await controller.sendPasswordResetOtp(
          phone: widget.request.phone,
        );
      }

      // ============================================================
      // SIGNUP / PHONE CHANGE
      // ============================================================

      else {
        await controller.resendOtp(
          phone: widget.request.phone,
        );
      }

      if (!mounted) {
        return;
      }

      _otpController.clear();
      _startTimer();

      AppSnackbar.success(
        context,
        'A new OTP has been sent.',
      );
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(
        context,
        error.message,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(
        context,
        'Unable to resend OTP. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              Text(
                'Verify your phone',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
                textAlign: TextAlign.center,
                maxLength: 6,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP',
                  counterText: '',
                ),
                onChanged: (value) {
                  if (value.length == 6) {
                    _verifyOtp();
                  }
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _verifyOtp,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Verify'),
                ),
              ),

              const SizedBox(height: 24),

              if (_secondsRemaining > 0)
                Text(
                  'Resend OTP in $_secondsRemaining seconds',
                  textAlign: TextAlign.center,
                )
              else
                TextButton(
                  onPressed: isLoading ? null : _resendOtp,
                  child: const Text('Resend OTP'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}