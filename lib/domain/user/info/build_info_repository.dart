import 'package:package_info/package_info.dart';

import '../../../dependency_locator.dart';
import '../../env.dart';
import 'build_info.dart';

class BuildInfoRepository {
  late final _envRepository = dependencyLocator<EnvRepository>();

  Future<BuildInfo> getBuildInfo({
    String? mergeRequestNumber,
    String? branch,
    String? tag,
  }) async {
    final info = await PackageInfo.fromPlatform();

    // Split the complete version string on dots and dashes, and
    // then combine the first 3 segments again, separated by dots.
    final fullVersionSplit = info.version.split(RegExp('[.-]'));
    final version = fullVersionSplit.take(3).join('.');

    return BuildInfo(
      version: version,
      buildNumber: info.buildNumber,
      mergeRequestNumber:
          mergeRequestNumber?.isNotEmpty ?? false ? mergeRequestNumber : null,
      branchName: branch?.isNotEmpty ?? false ? branch : null,
      tag: tag?.isNotEmpty ?? false ? tag : null,
      packageName: info.packageName,
      isProduction: _envRepository.isProduction,
    );
  }
}
