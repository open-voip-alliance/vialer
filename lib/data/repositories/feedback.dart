import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import '../../domain/repositories/feedback.dart';

class DataFeedbackRepository extends FeedbackRepository {
  @override
  Future<void> send({
    @required String title,
    @required String text,
    @required String email,
    @required String uuid,
    @required String platform,
    @required String brand,
  }) async {
    Logger('$runtimeType').info(
      'From: $email | '
      'From-Uuid: $uuid | '
      'From-Platform: $platform | '
      'From-Brand: $brand | '
      'Subject: $title | '
      '$text',
    );
  }
}
