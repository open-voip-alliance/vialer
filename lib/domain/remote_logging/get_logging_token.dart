import 'dart:async';
import 'dart:io';

import '../../dependency_locator.dart';
import '../env.dart';
import '../use_case.dart';

// TODO: Implementation detail, shouldn't be here
class GetLoggingTokenUseCase extends UseCase {
  final _envRepository = dependencyLocator<EnvRepository>();

  Future<String> call() async {
    final token = Platform.isAndroid
        ? await _envRepository.logentriesAndroidToken
        : Platform.isIOS
            ? await _envRepository.logentriesIosToken
            : '';

    return token;
  }
}
