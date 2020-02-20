import '../../domain/entities/recent_call.dart';
import '../../domain/repositories/recent_call.dart';

class DataRecentCallRepository extends RecentCallRepository {
  @override
  Future<List<RecentCall>> getRecentCalls() async {
    return List.generate(64, (i) {
      return RecentCall(
        isIncoming: i % 8 == 0,
        name: i % 6 == 0 ? 'Mark Vletter' : null,
        phoneNumber: '+315072000035',
        time: DateTime.now().subtract(Duration(minutes: i * 3)),
      );
    });
  }
}
