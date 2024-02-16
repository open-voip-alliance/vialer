import 'dart:async';

import '../../../data/models/user/info/build_info.dart';
import '../../../data/repositories/env.dart';
import '../../../data/repositories/user/info/build_info_repository.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';

class GetBuildInfoUseCase extends UseCase {
  final _buildInfoRepository = dependencyLocator<BuildInfoRepository>();
  final _envRepository = dependencyLocator<EnvRepository>();

  Future<BuildInfo> call() async => _buildInfoRepository.getBuildInfo(
        mergeRequestNumber: _envRepository.mergeRequest,
        branch: _envRepository.branch,
        tag: _envRepository.tag,
      );
}
