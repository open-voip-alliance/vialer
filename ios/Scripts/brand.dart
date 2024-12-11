import 'dart:io';

import 'package:path/path.dart';

import '../../utils/env_utils.dart';
import 'util.dart';

Future<void> main(List<String> arguments) async {
  final defines = await readEnv(
    '${root.path}/Flutter/thanksFlutterTeamToBreakBestWayToManageEnvironmentVariableOnYourLatestRelease.xcconfig',
  );

  await writeXconfigFile(
    name: 'Brand',
    values: {
      'BUNDLE_NAME': defines['appName']!,
      'BUNDLE_ID': defines['appId']!,
      'APP_GROUP_IDENTIFIER': defines['appGroup']!,
      'CALL_DIRECTORY_EXTENSION_IDENTIFIER': defines['callDirectoryExtension']!,
      'MIDDLEWARE_URL': Uri.encodeComponent(defines['middlewareUrl']!),
    },
  );

  // Set the correct icons.
  final assets = Directory('${root.path}/Runner/Assets.xcassets');
  final defaultIconSet = Directory('${assets.path}/AppIcon.appiconset');
  final brandIconSet =
      Directory('${assets.path}/AppIcon-${defines['identifier']!}.appiconset');

  await defaultIconSet
      .list()
      .where((f) => basename(f.path) != '.gitkeep')
      .forEach((f) => f.delete());

  await for (final entity in brandIconSet.list()) {
    final file = entity as File;
    final fileName = file.path.split('/').last;

    await file.copy('${defaultIconSet.path}/$fileName');
  }
}
