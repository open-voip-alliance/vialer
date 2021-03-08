import 'dart:async';
import 'dart:io';

import '../../dependency_locator.dart';
import '../repositories/env.dart';

import '../use_case.dart';

// TODO: Implementation detail, shouldn't be here
class GetLoggingTokenUseCase extends FutureUseCase<String> {
  final _envRepository = dependencyLocator<EnvRepository>();

  @override
  Future<String> call() async {
    if (Platform.isAndroid) {
      return _envRepository.logentriesAndroidToken;
    } else if (Platform.isIOS) {
      return _envRepository.logentriesIosToken;
    } else {
      throw UnsupportedError(
        'No logging token for platform: ${Platform.operatingSystem}',
      );
    }
  }
}
