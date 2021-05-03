import 'dart:async';

import '../use_case.dart';
import 'get_user.dart';

class GetIsAuthenticatedUseCase extends UseCase {
  final _getUser = GetUserUseCase();

  Future<bool> call() async {
    final user = await _getUser(latest: false);
    return user?.token != null;
  }
}
