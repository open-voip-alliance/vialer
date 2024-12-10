import 'dart:convert';
import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:collection/collection.dart';
import 'package:package_config/package_config.dart';
import 'package:vialer/data/models/user/brand.dart';
import 'package:vialer/presentation/resources/theme/brand_icon_code_points.dart';
import 'package:vialer/presentation/resources/theme/colors.dart';
import 'package:xml/xml.dart';
import 'package:yaml/yaml.dart';

import 'env_utils.dart';

/// Generates useful brand and other app values to natively used files.
///
/// Currently Android only.
Future<void> main(List<String> args) async {
  final brandIdentifier = args.elementAtOrNull(0);

  if (brandIdentifier == null) {
    throw ArgumentError('No brand identifier passed to script.');
  }

  final jsonString = File('brands/$brandIdentifier.json').readAsStringSync();
  final json = const JsonDecoder().convert(jsonString) as Map<String, dynamic>;
  final brand = Brand.fromJson(json);

  await Future.wait([
    writeEnvValues(),
    writeBrandValues(brand),
    writeColorValues(brand),
    writeLanguageValues(brand),
    copyBrandIcons(),
    copyFontAwesome(),
  ]);
}

Future<void> writeEnvValues() async {
  final builder = createXmlBuilder();

  final env = await readEnv('.env');

  builder.element(
    'resources',
    nest: () {
      for (final entry in env.entries) {
        builder.element(
          'string',
          attributes: {
            'name': entry.key.toLowerCase(),
          },
          nest: entry.value,
        );
      }
    },
  );

  await builder.buildDocument().writeToAndroidResource('env.xml');
}

Future<void> writeBrandValues(Brand brand) async {
  final builder = createXmlBuilder();

  builder.element(
    'resources',
    nest: () {
      final entries = brand.toJson().entries.followedBy([
        // Related to migrating users from the old app.
        MapEntry<String, dynamic>(
          'flutter_shared_pref_name',
          '${brand.appId}_preferences',
        ),
      ]);

      for (final entry in entries) {
        final name = StringUtils.camelCaseToLowerUnderscore(entry.key);
        final dynamic value = entry.value;

        builder.element(
          'string',
          attributes: {
            'name': name,
          },
          nest: value,
        );
      }

      builder.element(
        'integer',
        attributes: {
          'name': 'brand_icon',
        },
        // Not necessary to put in hex but makes more sense since it's referring
        // to a code point in Vialer Sans.
        nest: '0x${brand.iconCodePoint.toRadixString(16).toUpperCase()}',
      );
    },
  );

  await builder.buildDocument().writeToAndroidResource(
        'brand.xml',
        brand: brand,
      );
}

Future<void> writeColorValues(Brand brand) async {
  final builder = createXmlBuilder();

  final colors = brand.colors.toJson();

  builder.element(
    'resources',
    nest: () {
      for (final entry in colors.entries) {
        final name = StringUtils.camelCaseToLowerUnderscore(entry.key);
        final value = (entry.value as int).toRadixString(16).toUpperCase();

        builder.element(
          'color',
          attributes: {
            'name': name,
          },
          nest: '#$value',
        );
      }
    },
  );

  await builder.buildDocument().writeToAndroidResource(
        'colors.xml',
        brand: brand,
      );
}

Future<void> writeLanguageValues(Brand brand) async {
  Future<void> write({required String? locale}) async {
    final builder = createXmlBuilder();

    final localeOrEmpty = locale != null ? '_$locale' : '';
    final languageStrings = loadYaml(
      await File('lib/presentation/resources/messages$localeOrEmpty.i18n.yaml')
          .readAsString(),
    ) as YamlMap;

    void buildElementsRecursively(
      YamlMap strings, {
      String prefix = '',
    }) {
      // ignore: parameter_assignments
      prefix = prefix.isNotEmpty ? '${prefix}_' : '';

      for (final entry in strings.entries) {
        // Remove parameters, e.g. (String appName).
        final sanitizedKey = (entry.key as String).replaceAll(
          RegExp(r'\(.+\)'),
          '',
        );

        final name = StringUtils.camelCaseToLowerUnderscore(
          '$prefix$sanitizedKey',
        );
        final dynamic valueFromYaml = entry.value;

        if (valueFromYaml is YamlMap) {
          buildElementsRecursively(valueFromYaml, prefix: name);
          continue;
        }

        final value = (valueFromYaml as String?) ?? "";

        String sanitize(String value) {
          // Handle parameters, e.g. $appName to %1$s. We keep track of the
          // parameters since if for example $appName appears twice, it should
          // be replaced with %1$s in both cases, not %1$s and then %2$s.
          final parameters = <String, String>{};
          return value.replaceAllMapped(
            RegExp(r'(\$[A-z0-9]+)'),
            (match) {
              return parameters.putIfAbsent(
                match.group(0)!,
                () => '%${parameters.length + 1}\$s',
              );
            },
          ).replaceAll("'", r"\'");
        }

        final sanitizedValue = sanitize(value);

        // Check for plurals. We only support having two plural types (in our
        // case that would be mostly 'one' and 'many', but technically it could
        // be any as long as there are two).
        final pluralMatches = RegExp(
          r'''
        \${ *_plural\( *([A-z0-9]+), *([A-z0-9]+): *'(.*)', *([A-z0-9]+): *'(.*)' *\) *}
        '''
              .trim(),
        ).allMatches(value);

        for (final pluralMatch in pluralMatches) {
          final plurals = [1, 3].map(
            (i) => [pluralMatch.group(i + 1)!, pluralMatch.group(i + 2)!],
          );

          final fullMatch = pluralMatch.group(0)!;

          // Most of the time $count.
          final variable = '\$${pluralMatch.group(1)!}';

          // 'many' in our Dart i18n package means the same as 'other'
          // in Android.
          String validPluralType(String type) =>
              type == 'many' ? 'other' : type;

          builder.element(
            'plurals',
            attributes: {
              'name': name,
            },
            nest: () {
              for (final plural in plurals) {
                final pluralType = validPluralType(plural[0]);
                final pluralValue = plural[1];

                final fullPluralValue = value
                    .replaceAll(variable, '%d')
                    .replaceAll(fullMatch, pluralValue);

                builder.element(
                  'item',
                  attributes: {'quantity': pluralType},
                  nest: sanitize(fullPluralValue),
                );
              }
            },
          );
        }

        if (pluralMatches.isEmpty) {
          builder.element(
            'string',
            attributes: {
              'name': name,
            },
            nest: sanitizedValue,
          );
        }
      }
    }

    builder.element(
      'resources',
      nest: () {
        buildElementsRecursively(languageStrings);
      },
    );

    await builder.buildDocument().writeToAndroidResource(
          'strings.xml',
          brand: brand,
          locale: locale,
        );
  }

  await Future.wait([
    write(locale: null),
    write(locale: 'nl'),
    write(locale: 'de'),
  ]);
}

Future<void> copyBrandIcons() async {
  const fileName = 'brand_icons.ttf';

  await File('assets/$fileName').copy(
    await File('android/app/src/main/res/font/$fileName')
        .create(recursive: true)
        .then((f) => f.path),
  );
}

Future<void> copyFontAwesome() async {
  final packageConfig = (await findPackageConfig(Directory.current))!;

  const fontFileNames = [
    'fa-regular-400.ttf',
    'fa-solid-900.ttf',
  ];

  for (final fontFileName in fontFileNames) {
    final fontFile = File.fromUri(
      packageConfig.packages
          .firstWhere((p) => p.name == 'font_awesome_flutter')
          .root
          .resolve('lib/fonts/$fontFileName'),
    );

    final newFontFileName = fontFileName.replaceAll('-', '_');

    await fontFile.copy(
      await File('android/app/src/main/res/font/$newFontFileName')
          .create(recursive: true)
          .then((f) => f.path),
    );
  }
}

XmlBuilder createXmlBuilder() =>
    XmlBuilder()..processing('xml', 'version="1.0"');

extension on XmlDocument {
  Future<void> writeToAndroidResource(
    String path, {
    Brand? brand,
    String? locale,
  }) async {
    final rootPath = brand?.identifier ?? 'main';
    final localeOrEmpty = locale != null ? '-$locale' : '';
    await File('android/app/src/$rootPath/res/values$localeOrEmpty/$path')
        .create(recursive: true)
        .then((f) => f.writeAsString(toXmlString(pretty: true)));
  }
}
