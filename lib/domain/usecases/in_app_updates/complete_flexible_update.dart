import 'dart:async';
import 'dart:io';

import '../../../presentation/util/pigeon.dart';
import '../use_case.dart';

class CompleteFlexibleUpdateUseCase extends UseCase {
  Future<void> call() async {
    if (Platform.isAndroid) {
      await AppUpdates().completeAndroidFlexibleUpdate();
    }
  }
}
