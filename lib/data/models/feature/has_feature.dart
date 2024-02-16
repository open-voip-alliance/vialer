import '../../../dependency_locator.dart';
import '../../repositories/env.dart';
import 'feature.dart';

bool hasFeature(Feature feature) =>
    dependencyLocator<EnvRepository>().isFeatureFlagEnabled(feature);
bool doesNotHaveFeature(Feature feature) => !hasFeature(feature);
