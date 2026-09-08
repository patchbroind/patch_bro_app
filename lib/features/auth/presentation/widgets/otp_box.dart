// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class OtpBox extends StatefulWidget {
//   const OtpBox({super.key, 
//     required this.controller,
//     required this.focusNode,
//     required this.primaryColor,
//     required this.onChanged,
//     required this.onKeyEvent,
//   });

//   final TextEditingController controller;
//   final FocusNode focusNode;
//   final Color primaryColor;
//   final ValueChanged<String> onChanged;
//   final ValueChanged<KeyEvent> onKeyEvent;

//   @override
//   State<OtpBox> createState() => _OtpBoxState();
// }

// class _OtpBoxState extends State<OtpBox> {
//   late final FocusNode _keyboardFocusNode;

//   @override
//   void initState() {
//     super.initState();
//     _keyboardFocusNode = FocusNode();
//   }

//   @override
//   void dispose() {
//     _keyboardFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       // width: 72,
//       height: 72,
//       child: KeyboardListener(
//         focusNode: _keyboardFocusNode,
//         onKeyEvent: widget.onKeyEvent,
//         child: TextField(
//           controller: widget.controller,
//           focusNode: widget.focusNode,
//           textAlign: TextAlign.center,
//           keyboardType: TextInputType.number,
//           textInputAction: TextInputAction.next,
//           maxLength: 1,
//           cursorHeight: 28,
//           inputFormatters: [
//             FilteringTextInputFormatter.digitsOnly,
//           ],
//           style: TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.w700,
//             color: widget.primaryColor,
//           ),
//           decoration: const InputDecoration(
//             counterText: '',
//             contentPadding: EdgeInsets.zero,
//           ),
//           onChanged: widget.onChanged,
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpBox extends StatelessWidget {
  const OtpBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.primaryColor,
    required this.onChanged,
    this.size = 58,
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Color primaryColor;
  final ValueChanged<String> onChanged;
  final double size;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        maxLength: 1,
        cursorHeight: size * 0.38,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: size * 0.40,
          fontWeight: FontWeight.w700,
          color: primaryColor,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: theme.scaffoldBackgroundColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(
                alpha: 0.35,
              ),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: primaryColor,
              width: 2,
            ),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}