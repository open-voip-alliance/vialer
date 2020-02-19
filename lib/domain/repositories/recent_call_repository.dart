import '../entities/recent_call.dart';

abstract class RecentCallRepository {
  Future<List<RecentCall>> getRecentCalls();
}
