import 'dart:io';
import 'package:path/path.dart';
import 'package:vialer/domain/user/get_brand.dart';

import 'util.dart';

Future<void> main(List<String> arguments) async {
  final brand = GetBrand()();

  await writeXconfigFile(
    name: 'Brand',
    values: {
      'BUNDLE_NAME': brand.appName,
      'BUNDLE_ID': brand.appId,
      'MIDDLEWARE_URL': Uri.encodeComponent(brand.middlewareUrl.toString()),
    },
  );

  // Set the correct icons.
  final assets = Directory('${root.path}/Runner/Assets.xcassets');
  final defaultIconSet = Directory('${assets.path}/AppIcon.appiconset');
  final brandIconSet =
      Directory('${assets.path}/AppIcon-${brand.identifier}.appiconset');

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
