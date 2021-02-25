import 'dart:convert';
import 'dart:io';

// ignore: avoid_relative_lib_imports
import '../../lib/brands.dart';

Future<void> main(List<String> arguments) async {
  final dartDefines = arguments.isNotEmpty
      ? Map.fromEntries(
          arguments[0].split(',').map((keyValuePair) {
            final split = keyValuePair.split('%3D'); // %3D is '=' encoded

            return MapEntry(split[0], split[1]);
          }),
        )
      : {};

  final brandId = dartDefines['BRAND'] ?? 'vialer';
  final root = Directory(Platform.environment['SRCROOT']);
  final data = json.decode(brands) as List<dynamic>;

  final brand = data.singleWhere(
    (b) => (b as Map<String, dynamic>)['identifier'] == brandId,
  ) as Map<String, dynamic>;

  final brandConfig = File('${root.path}/Flutter/Brand.xconfig');

  await brandConfig.writeAsString(
    'BUNDLE_NAME=${brand['appName']}\n'
    'BUNDLE_ID=${brand['appId']}',
  );

  // Set the correct icons.
  final assets = Directory('${root.path}/Runner/Assets.xcassets');
  final defaultIconSet = Directory('${assets.path}/AppIcon.appiconset');
  final brandIconSet = Directory('${assets.path}/AppIcon-$brandId.appiconset');

  await defaultIconSet.list().forEach((e) => e.delete());

  await for (final entity in brandIconSet.list()) {
    final file = entity as File;
    final fileName = file.path.split('/').last;

    await file.copy('${defaultIconSet.path}/$fileName');
  }
}
