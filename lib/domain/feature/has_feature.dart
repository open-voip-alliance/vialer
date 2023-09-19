import '../../dependency_locator.dart';
import '../env.dart';
import '../use_case.dart';
import 'feature.dart';

/// Returns true if the given feature is enabled.
// TODO: Remove this usecase in a future merge request and only use the global
// function.
class HasFeature extends UseCase {
  final _env = dependencyLocator<EnvRepository>();

  bool call(Feature feature) => _env.isFeatureFlagEnabled(feature);
}

bool hasFeature(Feature feature) => HasFeature()(feature);
bool doesNotHaveFeature(Feature feature) => !HasFeature()(feature);
