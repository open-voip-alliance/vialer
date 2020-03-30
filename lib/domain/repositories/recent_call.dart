import 'package:meta/meta.dart';

import '../entities/call.dart';

// ignore: one_member_abstracts
abstract class RecentCallRepository {
  Future<List<Call>> getRecentCalls({@required int page});
}
