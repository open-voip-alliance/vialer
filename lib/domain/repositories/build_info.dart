import 'package:package_info/package_info.dart';

import '../entities/build_info.dart';

class BuildInfoRepository {
  Future<BuildInfo> getBuildInfo() async {
    final info = await PackageInfo.fromPlatform();

    final fullVersionSplit = info.version.split('-');

    final version = fullVersionSplit[0];

    String mr, branch;
    if (fullVersionSplit.length > 1) {
      final possibleMr = fullVersionSplit[1];

      if (possibleMr.startsWith('MR')) {
        mr = possibleMr.split('.')[1];
      }

      // Skip 2 dashes to get the branch if there's an MR, 1 otherwise.
      branch = fullVersionSplit.skip(mr != null ? 2 : 1).join('-');
    }

    return BuildInfo(
      version: version,
      buildNumber: info.buildNumber,
      mergeRequestNumber: mr,
      branchName: branch,
    );
  }
}
