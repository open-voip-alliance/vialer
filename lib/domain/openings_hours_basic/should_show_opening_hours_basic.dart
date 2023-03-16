import '../feature/feature.dart';
import '../feature/has_feature.dart';
import '../use_case.dart';
import '../user/get_logged_in_user.dart';

/// Whether the app should show opening hours based on the feature flag.
class ShouldShowOpeningHoursBasic extends UseCase {
  late final _hasFeature = HasFeature();
  late final _getUser = GetLoggedInUserUseCase();

  bool call() =>
      _hasFeature(Feature.openingHoursBasic) &&
      _getUser().permissions.canChangeOpeningHours;
}
