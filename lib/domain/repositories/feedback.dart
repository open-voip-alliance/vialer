import 'package:meta/meta.dart';
import '../entities/system_user.dart';

// ignore: one_member_abstracts
abstract class FeedbackRepository {
  Future<void> send({
    @required String title,
    @required String text,
    @required SystemUser user,
    @required String brand,
  });
}
