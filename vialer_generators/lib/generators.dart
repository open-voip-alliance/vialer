import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';
import 'package:vialer_generators/version_info/version_info_builder.dart';

import '../colors/color_generator.dart';

/// The extension that should be used for all stand-alone generated files. Only
/// relevant when using a [LibraryBuilder].
///
/// It is not necessary to use this when using SharedPartBuilder as that
/// automatically compiles them to the `.g.dart` file.
const extension = '.vialer.dart';

Builder colorsGeneratorBuilder(BuilderOptions options) =>
    LibraryBuilder(ColorsGenerator(), generatedExtension: extension);

Builder versionInfoBuilder(BuilderOptions options) => VersionInfoBuilder();
