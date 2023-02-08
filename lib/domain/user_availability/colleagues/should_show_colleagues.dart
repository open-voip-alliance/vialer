import '../../../app/util/loggable.dart';
import '../../feature/feature.dart';
import '../../feature/has_feature.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';

/// Whether the app should show colleagues. Takes into account the feature
/// flag and permissions.
class ShouldShowColleagues extends UseCase with Loggable {
  late final _hasFeature = HasFeature();
  late final _getUser = GetLoggedInUserUseCase();

  bool call() {
    final hasFeature = _hasFeature(Feature.colleagueList);
    final hasPermission = _getUser().permissions.canViewColleagues;

    final shouldShow = hasFeature && hasPermission;

    if (!shouldShow) {
      // Temporary log just while we are trying to resolve an issue with the
      // colleague list not showing.
      logger.info(
        'Not showing colleague list: '
        'hasFeature=$hasFeature | hasPermission=$hasPermission',
      );
    }

    return shouldShow;
  }
}
