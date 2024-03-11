import 'dart:async';

import 'package:package_info_plus/package_info_plus.dart';

import '../../../data/repositories/legacy/storage.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';

class GetDidAppUpdateToNewVersionUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  Future<bool> call() async {
    final currentVersion = await PackageInfo.fromPlatform().version;
    final lastInstalledVersion = _storageRepository.lastInstalledVersion;

    _storageRepository.lastInstalledVersion = currentVersion;

    // If there is no last installed version, this means it is a new install
    // rather than an update.
    if (lastInstalledVersion == null) return false;

    return currentVersion != lastInstalledVersion;
  }
}

extension PackageInfoVersion on Future<PackageInfo> {
  Future<String> get version => then((info) => info.version);
}
