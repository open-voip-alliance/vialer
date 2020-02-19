import '../entities/recent_call.dart';

abstract class CallRepository {
  Future<void> call(String destination);
}
