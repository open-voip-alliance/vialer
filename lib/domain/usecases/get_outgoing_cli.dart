import '../use_case.dart';
import 'get_user.dart';

class GetOutgoingCliUseCase extends FutureUseCase<String> {
  final _getUser = GetUserUseCase();

  @override
  Future<String> call() async {
    final user = await _getUser(latest: false);
    return user.outgoingCli;
  }
}
