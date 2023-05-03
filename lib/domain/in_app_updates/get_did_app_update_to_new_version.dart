import 'dart:async';

import 'package:package_info/package_info.dart';

import '../../dependency_locator.dart';
import '../legacy/storage.dart';
import '../use_case.dart';

class GetDidAppUpdateToNewVersionUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  Future<bool> call() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final lastInstalledVersion = _storageRepository.lastInstalledVersion;

    _storageRepository.lastInstalledVersion = currentVersion;

    // If there is no last installed version, this means it is a new install
    // rather than an update.
    if (lastInstalledVersion == null) return false;

    return currentVersion != lastInstalledVersion;
  }
}
