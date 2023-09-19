import '../../dependency_locator.dart';
import '../env.dart';
import 'feature.dart';

bool hasFeature(Feature feature) =>
    dependencyLocator<EnvRepository>().isFeatureFlagEnabled(feature);
bool doesNotHaveFeature(Feature feature) => !hasFeature(feature);
