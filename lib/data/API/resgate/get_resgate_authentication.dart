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

  /// Relations deploys their websockets with specific versions which allows
  /// new statuses and information to to be added while still allowing older
  /// clients to be supported.
  ///
  /// This version should only be upgraded when everything else has been
  /// updated to handle the updated payloads.
  static const version = 2;

  ResgateAuthentication? call() => _isOnboarded
      ? ResgateAuthentication(
          url: _brand.resgateUrl,
          token: _user.token ?? '',
        )
      : null;
}

@freezed
class ResgateAuthentication with _$ResgateAuthentication {
  const factory ResgateAuthentication({
    required Uri url,
    required String token,
  }) = _ResgateAuthentication;
}
