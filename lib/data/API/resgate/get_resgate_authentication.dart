import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/usecases/onboarding/is_onboarded.dart';
import '../../../domain/usecases/use_case.dart';
import '../../../domain/usecases/user/get_brand.dart';
import '../../../domain/usecases/user/get_logged_in_user.dart';
import '../../models/user/brand.dart';
import '../../models/user/user.dart';

part 'get_resgate_authentication.freezed.dart';

class GetResgateAuthentication extends UseCase {
  bool get _isOnboarded => IsOnboarded()();
  User get _user => GetLoggedInUserUseCase()();
  Brand get _brand => GetBrand()();

  ResgateAuthentication? call() {
    if (!_isOnboarded) return null;

    final token = _user.token;

    if (token == null) return null;

    return ResgateAuthentication(url: _brand.resgateUrl, token: token);
  }
}

@freezed
class ResgateAuthentication with _$ResgateAuthentication {
  const factory ResgateAuthentication({
    required Uri url,
    required String token,
  }) = _ResgateAuthentication;
}
