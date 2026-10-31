import 'package:flutter_test/flutter_test.dart';
import 'package:patch_bro/app/config/app_config.dart';
import 'package:patch_bro/core/theme/app_theme.dart';
import 'package:patch_bro/core/theme/employer/employer_colors.dart';
import 'package:patch_bro/core/theme/worker/worker_colors.dart';

void main() {
  test('each flavor resolves its own primary color scheme', () {
    final workerTheme = AppTheme.fromFlavor(AppFlavor.worker);
    final employerTheme = AppTheme.fromFlavor(AppFlavor.employer);

    expect(workerTheme.colorScheme.primary, WorkerColors.primary);
    expect(employerTheme.colorScheme.primary, EmployerColors.primary);
    expect(
      workerTheme.colorScheme.primary,
      isNot(employerTheme.colorScheme.primary),
    );
  });
}
