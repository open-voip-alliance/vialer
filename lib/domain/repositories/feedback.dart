import 'package:meta/meta.dart';

// ignore: one_member_abstracts
abstract class FeedbackRepository {
  Future<void> send({
    @required String title,
    @required String text,
    @required String email,
    @required String uuid,
    @required String platform,
    @required String brand,
  });
}
