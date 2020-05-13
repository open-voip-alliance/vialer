import 'package:package_info/package_info.dart';

import '../domain/entities/build_info.dart';

import '../domain/repositories/build_info.dart';
import '../domain/repositories/env.dart';

class DeviceBuildInfoRepository extends BuildInfoRepository {
  final EnvRepository _envRepository;

  DeviceBuildInfoRepository(this._envRepository);

  @override
  Future<BuildInfo> getBuildInfo() async {
    final info = await PackageInfo.fromPlatform();

    return BuildInfo(
      version: info.version,
      commit: await _envRepository.commitHash,
    );
  }
}
