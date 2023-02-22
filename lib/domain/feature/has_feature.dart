import 'package:recase/recase.dart';

import '../../dependency_locator.dart';
import '../env.dart';
import '../use_case.dart';
import 'feature.dart';

/// Returns true if the given feature is enabled.
class HasFeature extends UseCase {
  final _env = dependencyLocator<EnvRepository>();

  bool call(Feature feature) =>
      _env.get('FEATURE_${feature.name.constantCase}').isNotEmpty;
}
