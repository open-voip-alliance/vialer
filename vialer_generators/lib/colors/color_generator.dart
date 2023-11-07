import 'dart:async';

import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'package:analyzer/dart/element/element.dart';

/// Generates a `Colors` class that allows for easy access of colors defined
/// in `color_values.dart` within Flutter.
class ColorsGenerator extends Generator {
  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep step) async {
    final buffer = StringBuffer();

    buffer.writeln("import 'dart:ui';");
    buffer.writeln("import 'colors.dart';");
    buffer.writeln('class $_generatedClassName {');
    buffer.writeln('$_generatedClassName($_className v) : ');

    try {
      final colors = library.colorsClass.constructors.first.parameters;

      colors.forEach((element) {
        buffer.writeln('${element.name} = Color(v.${element.name})');
        buffer.write(element == colors.last ? ';' : ',');
      });

      colors.forEach((element) {
        buffer.writeln('final Color ${element.name};');
      });

      buffer.writeln('}');

      return buffer.toString();
    } on Exception {
      return null;
    }
  }
}

const _className = 'Colors';
const _generatedClassName = 'FlutterColors';

extension on LibraryReader {
  ClassElement get colorsClass {
    final colorValuesClass =
        classes.where((element) => element.name == _className).firstOrNull;

    if (colorValuesClass == null) {
      throw Exception('Unable to find $_className, is this the correct file?');
    }

    return colorValuesClass;
  }
}
