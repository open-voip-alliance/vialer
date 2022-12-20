import 'package:recase/recase.dart';

import '../../dependency_locator.dart';
import '../env.dart';
import '../use_case.dart';
import 'feature.dart';

/// Returns true if the given feature is enabled.
class HasFeature extends UseCase {
  final _env = dependencyLocator<EnvRepository>();

  Future<bool> call(Feature feature) async {
    final envName = feature.name.constantCase;
    final envValue = await _env.get('FEATURE_$envName');
    return envValue.isNotEmpty;
  }
}
