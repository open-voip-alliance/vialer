import 'dart:io';

import '../../../data/repositories/env.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';

// TODO: Implementation detail, shouldn't be here
class GetLoggingTokenUseCase extends UseCase {
  final _envRepository = dependencyLocator<EnvRepository>();

  String call() {
    final token = Platform.isAndroid
        ? _envRepository.logentriesAndroidToken
        : Platform.isIOS
            ? _envRepository.logentriesIosToken
            : '';

    if (token.isEmpty) {
      throw UnsupportedError(
        'No logging token for platform: ${Platform.operatingSystem}',
      );
    }

    return token;
  }
}
