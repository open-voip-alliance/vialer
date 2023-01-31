import 'dart:async';

import '../../dependency_locator.dart';
import '../env.dart';
import '../use_case.dart';
import 'info/build_info.dart';
import 'info/build_info_repository.dart';

class GetBuildInfoUseCase extends UseCase {
  final _buildInfoRepository = dependencyLocator<BuildInfoRepository>();
  final _envRepository = dependencyLocator<EnvRepository>();

  Future<BuildInfo> call() async => _buildInfoRepository.getBuildInfo(
        mergeRequestNumber: _envRepository.mergeRequest,
        branch: _envRepository.branch,
        tag: _envRepository.tag,
      );
}
