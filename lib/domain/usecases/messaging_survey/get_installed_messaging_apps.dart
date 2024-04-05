import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:vialer/domain/usecases/use_case.dart';

class GetInstalledMessagingApps extends UseCase {
  Future<List<String>> call() async {
    if (!Platform.isAndroid) {
      throw Exception(
        'We are only able to get Installed Messaging apps on Android',
      );
    }

    final apps = await InstalledApps.getInstalledApps(true);
    final packages = apps.map((app) => app.packageName);
    return packages.onlyRelevant;
  }
}

extension on Iterable<String> {
  /// The list of relevant messaging apps that we want to track.
  ///
  /// Note: When this list is updated you MUST also modify the AndroidManifest
  /// file found at:
  /// `android/app/src/main/AndroidManifest.xml`
  ///
  /// Add a new entry to the `<queries>` array such as:
  /// `<package android:name="com.whatsapp" />`
  ///
  /// Any package name that is not in both the manifest and this list will NOT
  /// be included in the survey results.
  static const _relevantApps = ['com.whatsapp'];

  List<String> get onlyRelevant =>
      filter((app) => _relevantApps.contains(app)).toList();
}
