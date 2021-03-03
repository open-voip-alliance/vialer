import '../use_case.dart';
import 'get_user.dart';

class GetHasVoipUseCase extends FutureUseCase<bool> {
  final _getUser = GetUserUseCase();

  @override
  Future<bool> call() async {
    final user = await _getUser(latest: false);
    return user?.appAccountId != null;
  }
}
