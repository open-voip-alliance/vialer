import 'package:package_info/package_info.dart';

import '../entities/build_info.dart';
import 'env.dart';

class BuildInfoRepository {
  final EnvRepository _envRepository;

  BuildInfoRepository(this._envRepository);

  Future<BuildInfo> getBuildInfo() async {
    final info = await PackageInfo.fromPlatform();

    // Split the complete version string on dots and dashes, and
    // then combine the first 3 segments again, separated by dots.
    final fullVersionSplit = info.version.split(RegExp(r'[.-]'));
    final version = fullVersionSplit.take(3).join('.');

    return BuildInfo(
      version: version,
      buildNumber: info.buildNumber,
      mergeRequestNumber: await _envRepository.mergeRequest,
      branchName: await _envRepository.branch,
    );
  }
}
