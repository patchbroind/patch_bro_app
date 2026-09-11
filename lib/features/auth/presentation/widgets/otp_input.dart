import 'package:flutter/material.dart';
import 'package:patch_bro/features/auth/presentation/widgets/otp_box.dart';

class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.controller,
    this.length = 6,
    this.enabled = true,
    this.onCompleted,
  });

  final TextEditingController controller;
  final int length;
  final bool enabled;
  final ValueChanged<String>? onCompleted;

  @override
  OtpInputState createState() => OtpInputState();
}

class OtpInputState extends State<OtpInput> {
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

    _syncFromParentController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.enabled) {
        focusFirstBox();
      }
    });
  }

  @override
  void didUpdateWidget(
    covariant OtpInput oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      _syncFromParentController();
    }

    if (!oldWidget.enabled && widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          focusFirstBox();
        }
      });
    }
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

  // ---------------------------------------------------------------------------
  // PUBLIC METHODS
  // ---------------------------------------------------------------------------

  void focusFirstBox() {
    if (!widget.enabled || _focusNodes.isEmpty) {
      return;
    }

    _focusNodes.first.requestFocus();
  }

  void clear() {
    for (final controller in _controllers) {
      controller.clear();
    }

    _updateOtp();

    if (mounted && widget.enabled) {
      focusFirstBox();
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE OTP
  // ---------------------------------------------------------------------------

  void _updateOtp() {
    final otp = _controllers
        .map((controller) => controller.text)
        .join();

    widget.controller.value = TextEditingValue(
      text: otp,
      selection: TextSelection.collapsed(
        offset: otp.length,
      ),
    );

    if (otp.length == widget.length) {
      widget.onCompleted?.call(otp);
    }
  }

  // ---------------------------------------------------------------------------
  // SYNC
  // ---------------------------------------------------------------------------

  void _syncFromParentController() {
    final digits = widget.controller.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].text =
          i < digits.length ? digits[i] : '';
    }
  }

  // ---------------------------------------------------------------------------
  // CHANGE
  // ---------------------------------------------------------------------------

  void _handleChanged(
    int index,
    String value,
  ) {
    // Some platforms can provide more than one
    // character when the user pastes an OTP.
    if (value.length > 1) {
      _handlePaste(
        index,
        value,
      );
      return;
    }

    // Normal single digit input.
    if (value.isNotEmpty &&
        index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    _updateOtp();
  }

  // ---------------------------------------------------------------------------
  // PASTE
  // ---------------------------------------------------------------------------

  void _handlePaste(
    int index,
    String value,
  ) {
    final digits = value.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (digits.isEmpty) {
      return;
    }

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

    if (mounted) {
      setState(() {});
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        Theme.of(context).colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;

        final availableWidth = constraints.maxWidth;

        final calculatedSize =
            (availableWidth -
                    (spacing * (widget.length - 1))) /
                widget.length;

        final boxSize = calculatedSize.clamp(
          42.0,
          58.0,
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.length,
            (index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == widget.length - 1
                      ? 0
                      : spacing,
                ),
                child: OtpBox(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  primaryColor: primaryColor,
                  enabled: widget.enabled,
                  size: boxSize,
                  onChanged: (value) {
                    _handleChanged(
                      index,
                      value,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}