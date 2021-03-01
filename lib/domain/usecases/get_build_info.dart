import 'dart:async';

import '../../dependency_locator.dart';
import '../entities/build_info.dart';
import '../repositories/build_info.dart';
import '../repositories/env.dart';
import '../use_case.dart';

class GetBuildInfoUseCase extends FutureUseCase<BuildInfo> {
  final _buildInfoRepository = dependencyLocator<BuildInfoRepository>();
  final _envRepository = dependencyLocator<EnvRepository>();

  @override
  Future<BuildInfo> call() async => _buildInfoRepository.getBuildInfo(
        mergeRequestNumber: await _envRepository.mergeRequest,
        branch: await _envRepository.branch,
      );
}
