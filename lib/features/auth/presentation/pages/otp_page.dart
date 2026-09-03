import 'dart:async';

import 'package:flutter/material.dart';
import 'package:patch_bro/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patch_bro/core/utils/app_snackbar.dart';
import 'package:patch_bro/features/auth/presentation/models/otp_verification_args.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../providers/auth_providers.dart';
import '../widgets/otp_input.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({super.key, required this.request});

  final OtpVerificationArgs request;

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final _otpController = TextEditingController();

  Timer? _timer;
  int _remainingSeconds = 59;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();

    _remainingSeconds = 59;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();

        setState(() {
          _remainingSeconds = 0;
        });

        return;
      }

      setState(() {
        _remainingSeconds--;
      });
    });
  }

  Future<void> _verifyOtp() async {
    final token = _otpController.text.trim();

    if (token.length != 6) {
      AppSnackbar.error(context, 'Please enter the 6-digit OTP');

      return;
    }

    FocusScope.of(context).unfocus();

    try {
      final authController = ref.read(authControllerProvider.notifier);

      // ======================================================
      // Phone change verification
      // ======================================================

      if (widget.request.type == OtpVerificationType.phoneChange) {
        await authController.verifyPhoneChangeOtp(phone: widget.request.phone, token: token);

        final profileData = widget.request.profileData;

        if (profileData == null) {
          throw const AuthException('Profile information is missing.');
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
      }

      // ======================================================
      // Normal signup OTP
      // ======================================================

      await authController.verifyOtp(phone: widget.request.phone, token: token);

      if (!mounted) {
        return;
      }

      context.go('/profile-details');
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(context, error.toString());
    }
  }

  Future<void> _resendOtp() async {
    if (_remainingSeconds > 0) {
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).resendOtp(phone: widget.request.phone);

      if (!mounted) {
        return;
      }

      _otpController.clear();
      _startTimer();

      AppSnackbar.error(context, "OTP sent again");
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(context, error.toString());
    }
  }

  String get _formattedTime {
    final seconds = _remainingSeconds.toString().padLeft(2, '0');

    return '00:$seconds';
  }

  String get _message {
    if (widget.request.type == OtpVerificationType.phoneChange) {
      return 'We have sent a verification code\n'
          'to your mobile number';
    }

    return 'We have sent a verification code\n'
        'to your mobile number';
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final authState = ref.watch(authControllerProvider);

    return AuthScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 35, 28, 32),
        child: Column(
          children: [
            Image.asset(
              'assets/images/otp_image.png',
              width: 330,
              height: 330,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 10),

            Text(
              'Verification Code',
              textAlign: TextAlign.center,
              style: TextStyle(color: primaryColor, fontSize: 34, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 22),

            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, height: 1.45, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 26),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: primaryColor.withValues(alpha: 0.12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_outlined, size: 26),
                  const SizedBox(width: 10),
                  Text(
                    _formattedTime,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 55),

            OtpInput(controller: _otpController),

            const SizedBox(height: 60),

            AppPrimaryButton(
              label: 'Verify',
              isLoading: authState.isLoading,
              onPressed: _verifyOtp,
            ),

            const SizedBox(height: 58),

            Row(
              children: [
                const Expanded(child: Divider()),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Didn't receive code?",
                    style: TextStyle(color: AppColors.textMuted, fontSize: 18),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 28),

            TextButton(
              onPressed: authState.isLoading || _remainingSeconds != 0 ? null : _resendOtp,
              child: Text(
                'Resend OTP',
                style: TextStyle(
                  color: _remainingSeconds == 0 ? primaryColor : AppColors.textDisabled,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
