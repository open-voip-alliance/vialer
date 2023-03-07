import '../feature/feature.dart';
import '../feature/has_feature.dart';
import '../use_case.dart';

/// Whether the app should show opening hours based on the feature flag.
class ShouldShowOpeningHoursBasic extends UseCase {
  late final _hasFeature = HasFeature();

  // bool call() => _hasFeature(Feature.openingHoursBasic);

  bool call() {
    final b = _hasFeature(Feature.openingHoursBasic);
    return b;
  }
}
