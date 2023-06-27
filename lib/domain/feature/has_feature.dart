import '../use_case.dart';
import 'feature.dart';

/// Returns true if the given feature is enabled.
class HasFeature extends UseCase {
  bool call(Feature feature) => true;
}
