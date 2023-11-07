import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';

import '../colors/color_generator.dart';

/// The extension that should be used for all stand-alone generated files. Only
/// relevant when using a [LibraryBuilder].
///
/// It is not necessary to use this when using SharedPartBuilder as that
/// automatically compiles them to the `.g.dart` file.
const extension = '.vialer.dart';

Builder colorsGeneratorBuilder(BuilderOptions options) =>
    LibraryBuilder(ColorsGenerator(), generatedExtension: extension);
