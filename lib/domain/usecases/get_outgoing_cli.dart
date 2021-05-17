import '../use_case.dart';
import 'get_user.dart';

class GetOutgoingCliUseCase extends UseCase {
  final _getUser = GetUserUseCase();

  Future<String?> call() async {
    final user = await _getUser(latest: false);
    return user!.outgoingCli;
  }
}
