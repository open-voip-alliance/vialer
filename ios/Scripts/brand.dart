import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';

// ignore: avoid_relative_lib_imports
import '../../lib/brands.dart';
import 'util.dart';

Future<void> main(List<String> arguments) async {
  final dartDefines = parseDartDefinesFromArguments(arguments);

  final brandId = dartDefines['BRAND'] ?? 'vialer';
  final data = json.decode(brands) as List<dynamic>;

  final brand = data.singleWhere(
    (b) => (b as Map<String, dynamic>)['identifier'] == brandId,
  ) as Map<String, dynamic>;

  await writeXconfigFile(
    name: 'Brand',
    values: {
      'BUNDLE_NAME': brand['appName'] as String,
      'BUNDLE_ID': brand['appId'] as String,
    },
  );

  // Set the correct icons.
  final assets = Directory('${root.path}/Runner/Assets.xcassets');
  final defaultIconSet = Directory('${assets.path}/AppIcon.appiconset');
  final brandIconSet = Directory('${assets.path}/AppIcon-$brandId.appiconset');

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
