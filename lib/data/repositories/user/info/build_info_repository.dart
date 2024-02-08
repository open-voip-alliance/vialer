import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../dependency_locator.dart';
import '../../../models/user/info/build_info.dart';
import '../../env.dart';

@singleton
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
