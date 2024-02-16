import 'package:injectable/injectable.dart';

import '../../../../presentation/util/loggable.dart';
import '../../../API/business_insights/feature_announcements/feature_announcements_service.dart';

@injectable
class FeatureAnnouncementsRepository with Loggable {
  FeatureAnnouncementsRepository(this._service);

  final FeatureAnnouncementsService _service;

  Future<bool> hasUnreadFeatureAnnouncements() async {
    final response = await _service.getUnreadAnnouncements();

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Get unread feature announcements');
      return false;
    }

    return response.headers.containsKey('x-unread-announcements') &&
        (int.tryParse(response.headers['x-unread-announcements']!) ?? 0) > 0;
  }
}
