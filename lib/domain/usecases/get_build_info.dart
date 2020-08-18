import 'dart:async';

import '../entities/build_info.dart';
import '../repositories/build_info.dart';
import '../use_case.dart';

class GetBuildInfoUseCase extends FutureUseCase<BuildInfo> {
  final BuildInfoRepository _buildInfoRepository;

  GetBuildInfoUseCase(this._buildInfoRepository);

  @override
  Future<BuildInfo> call() => _buildInfoRepository.getBuildInfo();
}
