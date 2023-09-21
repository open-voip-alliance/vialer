import '../../../app/util/loggable.dart';
import 'feature_announcements_service.dart';

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
