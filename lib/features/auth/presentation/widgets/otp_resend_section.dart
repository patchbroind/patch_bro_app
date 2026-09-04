import 'dart:async';

import 'package:flutter/material.dart';

class OtpResendSection extends StatefulWidget {
  const OtpResendSection({
    super.key,
    required this.onResend,
    required this.enabled,
  });

  final Future<void> Function() onResend;
  final bool enabled;

  @override
  State<OtpResendSection> createState() => _OtpResendSectionState();
}

class _OtpResendSectionState extends State<OtpResendSection> {
  Timer? _timer;
  int _secondsRemaining = 59;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant OtpResendSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.enabled && widget.enabled) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _secondsRemaining = 59;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    });
  }

  Future<void> _handleResend() async {
    if (_secondsRemaining > 0 || !widget.enabled) {
      return;
    }

    await widget.onResend();
    if (mounted) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_secondsRemaining > 0) {
      return Text(
        'Resend OTP in $_secondsRemaining seconds',
        textAlign: TextAlign.center,
      );
    }

    return TextButton(
      onPressed: widget.enabled ? _handleResend : null,
      child: const Text('Resend OTP'),
    );
  }
}
