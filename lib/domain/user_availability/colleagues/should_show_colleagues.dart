import '../../feature/feature.dart';
import '../../feature/has_feature.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';

/// Whether the app should show colleagues. Takes into account the feature
/// flag and permissions.
class ShouldShowColleagues extends UseCase {
  late final _hasFeature = HasFeature();
  late final _getUser = GetLoggedInUserUseCase();

  bool call() =>
      _hasFeature(Feature.colleagueList) &&
      _getUser().permissions.canViewColleagues;
}
