import 'package:flutter/widgets.dart';
import 'package:patch_bro/core/theme/app_colors.dart';

class InvitationExpiryText
    extends StatelessWidget {
  const InvitationExpiryText({
    super.key,
    required this.expiresAt,
  });

  final DateTime expiresAt;

  @override
  Widget build(
    BuildContext context,
  ) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now(),
      ),
      initialData: DateTime.now(),
      builder: (
        context,
        snapshot,
      ) {
        final now =
            snapshot.data ??
                DateTime.now();

        final remaining =
            expiresAt.difference(now);

        if (remaining.isNegative ||
            remaining.inSeconds <= 0) {
          return const Text(
            'Expired',
            style: TextStyle(
              color:
                  AppColors.error,
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          );
        }

        final minutes =
            remaining.inMinutes
                .toString()
                .padLeft(2, '0');

        final seconds =
            (remaining.inSeconds %
                    60)
                .toString()
                .padLeft(2, '0');

        return Text(
          'Expires in $minutes:$seconds',
          style: const TextStyle(
            color:
                AppColors.info,
            fontSize: 12,
            fontWeight:
                FontWeight.w600,
          ),
        );
      },
    );
  }
}