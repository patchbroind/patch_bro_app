import 'package:flutter/material.dart';

/// A reusable widget for displaying network images.
///
/// Features:
/// - Displays a loading indicator while the image loads.
/// - Displays a fallback icon when the URL is empty or invalid.
/// - Supports custom width, height, fit, and border radius.
/// - Supports a custom fallback widget.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallback,
    this.backgroundColor,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? fallback;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';

    final Widget image;

    if (url.isEmpty) {
      image = _buildFallback();
    } else {
      image = Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return SizedBox(
            width: width,
            height: height,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback();
        },
      );
    }

    if (borderRadius == null) {
      return image;
    }

    return ClipRRect(
      borderRadius: borderRadius!,
      child: image,
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey.shade100,
      alignment: Alignment.center,
      child: fallback ??
          Icon(
            Icons.image_not_supported_outlined,
            size: 28,
            color: Colors.grey.shade500,
          ),
    );
  }
}
