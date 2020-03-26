import 'dart:async';

import 'package:meta/meta.dart';
import 'package:chopper/chopper.dart';

import '../../../domain/repositories/auth.dart';

part 'voipgrid.chopper.dart';

@ChopperApi(baseUrl: '/api/')
abstract class VoipgridService extends ChopperService {
  static VoipgridService create({
    @required Uri baseUrl,
    AuthRepository authRepository,
  }) {
    return _$VoipGridService(
      ChopperClient(
        baseUrl: baseUrl.toString(),
        converter: JsonConverter(),
        interceptors: [_AuthorizationInterceptor(authRepository)],
      ),
    );
  }

  @Post(path: 'permission/apitoken/')
  Future<Response> getToken(@Body() Map<String, dynamic> body);

  @Get(path: 'permission/systemuser/profile/')
  Future<Response> getSystemUser();
}

class _AuthorizationInterceptor implements RequestInterceptor {
  final AuthRepository _authRepository;

  _AuthorizationInterceptor(this._authRepository);

  @override
  FutureOr<Request> onRequest(Request request) {
    final user = _authRepository.currentUser;

    if (user != null) {
      return request.replace(
        headers: Map.of(request.headers)
          ..addAll({
            'Authorization': 'Token ${user.email}:${user.token}',
          }),
      );
    } else {
      return request;
    }
  }
}
