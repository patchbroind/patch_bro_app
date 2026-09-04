import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:patch_bro/features/auth/presentation/widgets/otp_box.dart';

class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.controller,
    this.length = 6,
  });

  final TextEditingController controller;
  final int length;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );

    _focusNodes = List.generate(
      widget.length,
      (_) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  void _updateOtp() {
    widget.controller.text = _controllers.map((e) => e.text).join();
  }

  void _handleChanged(
    int index,
    String value,
  ) {
    if (value.length > 1) {
      _handlePaste(
        index,
        value,
      );
      return;
    }

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    _updateOtp();
  }

  void _handlePaste(
    int index,
    String value,
  ) {
    final digits = value.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    for (var i = 0; i < digits.length; i++) {
      final targetIndex = index + i;

      if (targetIndex >= widget.length) {
        break;
      }

      _controllers[targetIndex].text = digits[i];
    }

    _updateOtp();

    final nextIndex = index + digits.length;

    if (nextIndex < widget.length) {
      _focusNodes[nextIndex].requestFocus();
    } else {
      _focusNodes.last.unfocus();
    }
  }

  void _handleKeyEvent(
    int index,
    KeyEvent event,
  ) {
    if (event is! KeyDownEvent) {
      return;
    }

    if (event.logicalKey != LogicalKeyboardKey.backspace) {
      return;
    }

    if (_controllers[index].text.isNotEmpty) {
      _controllers[index].clear();
      _updateOtp();
      return;
    }

    if (index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      _updateOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        widget.length,
        (index) {
          return Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: OtpBox(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                primaryColor: primaryColor,
                onChanged: (value) {
                  _handleChanged(
                    index,
                    value,
                  );
                },
                onKeyEvent: (event) {
                  _handleKeyEvent(
                    index,
                    event,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

