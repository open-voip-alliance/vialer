import 'dart:async';
import 'dart:io';

import '../../dependency_locator.dart';
import '../repositories/env.dart';

import '../use_case.dart';

// TODO: Implementation detail, shouldn't be here
class GetLoggingTokenUseCase extends UseCase {
  final _envRepository = dependencyLocator<EnvRepository>();

  Future<String> call() {
    if (Platform.isAndroid) {
      return _envRepository.logentriesAndroidToken.then((t) => t!);
    } else if (Platform.isIOS) {
      return _envRepository.logentriesIosToken.then((t) => t!);
    } else {
      throw UnsupportedError(
        'No logging token for platform: ${Platform.operatingSystem}',
      );
    }
  }
}
