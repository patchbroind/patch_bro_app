import 'package:flutter/material.dart';

enum SocialProvider {
  apple,
  google,
}

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.label,
    required this.onPressed,
  });

  final SocialProvider provider;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isApple = provider == SocialProvider.apple;

    return SizedBox(
      height: 58,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isApple ? Colors.black : Colors.white,
          foregroundColor: isApple ? Colors.white : Colors.black87,
          side: BorderSide(
            color: isApple
                ? Colors.black
                : const Color(0xFFE0E0E0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialLogo(
              provider: provider,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialLogo extends StatelessWidget {
  const _SocialLogo({
    required this.provider,
  });

  final SocialProvider provider;

  @override
  Widget build(BuildContext context) {
    switch (provider) {
      case SocialProvider.apple:
        return Image.asset(
          'assets/images/apple_logo.png',
          width: 22,
          height: 22,
          fit: BoxFit.contain,color: Colors.white,
        );

      case SocialProvider.google:
        return const _GoogleLogo();
    }
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 23,
        fontWeight: FontWeight.w800,
        color: Color(0xFF4285F4),
      ),
    );
  }
}