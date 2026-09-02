import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/auth_scaffold.dart';
import '../providers/auth_providers.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../widgets/otp_input.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({super.key, required this.phone});

  final String phone;

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter the 6-digit OTP')));

      return;
    }

    FocusScope.of(context).unfocus();

    try {
      await ref.read(authControllerProvider.notifier).verifyOtp(phone: widget.phone, token: token);

      if (!mounted) {
        return;
      }

      final user = await ref
          .read(authControllerProvider.notifier)
          .verifyOtp(phone: widget.phone, token: _otpController.text);

      debugPrint('AUTH USER ID: ${user.id}');
      debugPrint('AUTH PHONE: ${user.phone}');
      debugPrint('AUTH EMAIL: ${user.email}');

      context.go('/profile-details');
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _resendOtp() async {
    if (_remainingSeconds > 0) {
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).resendOtp(phone: widget.phone);

      if (!mounted) {
        return;
      }

      _otpController.clear();
      _startTimer();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP sent again')));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  String get _formattedTime {
    final seconds = _remainingSeconds.toString().padLeft(2, '0');
    return '00:$seconds';
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

            const Text(
              'We have sent a verification code\n'
              'to your mobile number',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, height: 1.45, fontWeight: FontWeight.w500),
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
                    style: TextStyle(color: Color(0xFF777B88), fontSize: 18),
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
                  color: _remainingSeconds == 0 ? primaryColor : Colors.grey,
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
