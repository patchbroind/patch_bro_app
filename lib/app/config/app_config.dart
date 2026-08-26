enum AppFlavor {
  worker,
  employer,
}

class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
  });

  final AppFlavor flavor;
  final String appName;

  bool get isWorker => flavor == AppFlavor.worker;

  bool get isEmployer => flavor == AppFlavor.employer;

  static AppConfig fromEnvironment() {
    const flavor = String.fromEnvironment(
      'APP_FLAVOR',
      defaultValue: 'worker',
    );

    switch (flavor) {
      case 'employer':
        return const AppConfig(
          flavor: AppFlavor.employer,
          appName: 'Patch Bro Employer',
        );

      case 'worker':
      default:
        return const AppConfig(
          flavor: AppFlavor.worker,
          appName: 'Patch Bro Worker',
        );
    }
  }
}