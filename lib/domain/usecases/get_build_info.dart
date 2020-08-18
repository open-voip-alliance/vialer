import 'dart:async';

import '../../dependency_locator.dart';
import '../entities/build_info.dart';
import '../repositories/build_info.dart';
import '../use_case.dart';

class GetBuildInfoUseCase extends FutureUseCase<BuildInfo> {
  final _buildInfoRepository = dependencyLocator<BuildInfoRepository>();

  @override
  Future<BuildInfo> call() => _buildInfoRepository.getBuildInfo();
}
