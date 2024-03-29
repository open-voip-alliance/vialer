import 'package:vialer/data/models/user/settings/app_setting.dart';

import '../../../../../dependency_locator.dart';
import '../../../../repositories/business_insights/feature_announcements/feature_announcements_repository.dart';
import '../../user.dart';
import '../user_refresh_task_performer.dart';

class RefreshUserHasUnreadFeatureAnnouncements
    extends SettingsRefreshTaskPerformer {
  const RefreshUserHasUnreadFeatureAnnouncements();

  FeatureAnnouncementsRepository get _repository =>
      dependencyLocator<FeatureAnnouncementsRepository>();

  @override
  Future<SettingsMutator> performSettingsRefreshTask(User user) async {
    try {
      final hasUnread = await _repository.hasUnreadFeatureAnnouncements();

      return (User user) => (
            AppSetting.hasUnreadFeatureAnnouncements,
            hasUnread,
          );
    } catch (e) {
      return null;
    }
  }
}
