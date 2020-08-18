import 'package:package_info/package_info.dart';

import '../entities/build_info.dart';

import 'env.dart';

class BuildInfoRepository {
  final EnvRepository _envRepository;

  BuildInfoRepository(this._envRepository);

  Future<BuildInfo> getBuildInfo() async {
    final info = await PackageInfo.fromPlatform();

    return BuildInfo(
      version: info.version,
      commit: await _envRepository.commitHash,
    );
  }
}
