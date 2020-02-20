import '../entities/recent_call.dart';

// ignore: one_member_abstracts
abstract class RecentCallRepository {
  Future<List<RecentCall>> getRecentCalls();
}
