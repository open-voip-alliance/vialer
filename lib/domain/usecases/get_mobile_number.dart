import '../use_case.dart';
import 'get_user.dart';

class GetMobileNumberUseCase extends UseCase {
  final _getUser = GetUserUseCase();

  Future<String?> call({bool latest = false}) async {
    var user = await _getUser(latest: latest);

    return user?.mobileNumber;
  }
}
