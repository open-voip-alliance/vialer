import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:vialer/app/resources/theme/raw_colors.dart';
import 'package:vialer/app/resources/theme/raw_logo.dart';
import 'package:vialer/domain/entities/brand.dart';
import 'package:vialer/domain/repositories/brand.dart';
import 'package:xml/xml.dart';
import 'package:yaml/yaml.dart';

/// Generates useful brand and other app values to natively used files.
///
/// Currently Android only.
Future<void> main() async {
  final brands = BrandRepository().getBrands();

  await Future.wait([
    for (final brand in brands) ...[
      writeBrandValues(brand),
      writeColorValues(brand),
      writeLanguageValues(brand),
    ],
    copyVialerSans(),
  ]);
}

Future<void> writeBrandValues(Brand brand) async {
  final builder = createXmlBuilder();

  builder.element('resources', nest: () {
    final entries = brand.toJson().entries.followedBy([
      // Related to migrating users from the old app.
      MapEntry(
        'flutter_shared_pref_name',
        '${brand.appId}_preferences',
      )
    ]);

    for (final entry in entries) {
      final name = StringUtils.camelCaseToLowerUnderscore(entry.key);
      final value = entry.value;

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
        'name': 'logo',
      },
      // Not necessary to put in hex but makes more sense since it's referring
      // to a code point in Vialer Sans.
      nest: '0x${brand.rawLogo.toRadixString(16).toUpperCase()}',
    );
  });

  await builder.buildDocument().writeToAndroidResource(brand, 'brand.xml');
}

Future<void> writeColorValues(Brand brand) async {
  final builder = createXmlBuilder();

  final colors = brand.rawColors.toJson();

  builder.element('resources', nest: () {
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
  });

  await builder.buildDocument().writeToAndroidResource(brand, 'colors.xml');
}

Future<void> writeLanguageValues(Brand brand) async {
  Future<void> write({required bool dutch}) async {
    final builder = createXmlBuilder();

    final nlOrEmpty = dutch ? '_nl' : '';
    final languageStrings = loadYaml(
      await File('lib/app/resources/messages$nlOrEmpty.i18n.yaml')
          .readAsString(),
    ) as YamlMap;

    void buildElementsRecursively(
      YamlMap strings, {
      String prefix = '',
    }) {
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
        final value = entry.value;

        if (value is YamlMap) {
          buildElementsRecursively(value, prefix: name);
          continue;
        }

        value as String;

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
          ).replaceAll('\'', '\\\'');
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

    builder.element('resources', nest: () {
      buildElementsRecursively(languageStrings);
    });

    await builder.buildDocument().writeToAndroidResource(
          brand,
          'strings.xml',
          dutch: dutch,
        );
  }

  await Future.wait([write(dutch: false), write(dutch: true)]);
}

Future<void> copyVialerSans() async =>
    await File('assets/vialer_sans.ttf').copy(
      await File('android/app/src/main/res/font/vialer_sans.ttf')
          .create(recursive: true)
          .then((f) => f.path),
    );

XmlBuilder createXmlBuilder() =>
    XmlBuilder()..processing('xml', 'version="1.0"');

extension on XmlDocument {
  Future<void> writeToAndroidResource(
    Brand brand,
    String path, {
    bool dutch = false,
  }) async {
    final nlOrEmpty = dutch ? '-nl' : '';
    await File('android/app/src/${brand.identifier}/res/values$nlOrEmpty/$path')
        .create(recursive: true)
        .then((f) => f.writeAsString(toXmlString(pretty: true)));
  }
}
