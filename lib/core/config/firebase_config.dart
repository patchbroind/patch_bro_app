
import 'package:firebase_core/firebase_core.dart';

import '../../app/config/app_config.dart';
import '../../firebase_options_worker.dart' as worker;
import '../../firebase_options_employer.dart' as employer;

class FirebaseConfig {
  static FirebaseOptions optionsFor(AppConfig config) {
    if (config.isWorker) {
      return worker.DefaultFirebaseOptions.currentPlatform;
    }

    return employer.DefaultFirebaseOptions.currentPlatform;
  }
}