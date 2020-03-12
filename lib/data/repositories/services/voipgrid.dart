import 'dart:async';

import 'package:meta/meta.dart';
import 'package:chopper/chopper.dart';

part 'voipgrid.chopper.dart';

@ChopperApi()
abstract class VoipGridService extends ChopperService {
  static VoipGridService create({
    @required Uri baseUrl,
    String email,
    String token,
  }) {
    return _$VoipGridService(
      ChopperClient(
        baseUrl: baseUrl.toString(),
        converter: JsonConverter(),
        interceptors: email != null && token != null
            ? [_AuthorizationInterceptor(email, token)]
            : [],
      ),
    );
  }

  @Post(path: 'api/permission/apitoken/')
  Future<Response> getToken(@Body() Map<String, dynamic> body);

  @Get(path: 'api/permission/systemuser/profile/')
  Future<Response> getSystemUser();
}

class _AuthorizationInterceptor implements RequestInterceptor {
  final String email;
  final String token;

  _AuthorizationInterceptor(this.email, this.token);

  @override
  FutureOr<Request> onRequest(Request request) {
    return request.replace(
      headers: Map.of(request.headers)
        ..addAll({
          'Authorization': 'Token $email:$token',
        }),
    );
  }
}
