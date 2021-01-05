import 'dart:async';
import 'package:meta/meta.dart';
import 'package:chopper/chopper.dart';

import '../../../dependency_locator.dart';
import '../../../domain/repositories/auth.dart';

part 'voipgrid.chopper.dart';

@ChopperApi(baseUrl: '/api/')
abstract class VoipgridService extends ChopperService {
  static VoipgridService create({@required Uri baseUrl}) {
    return _$VoipgridService(
      ChopperClient(
        baseUrl: baseUrl.toString(),
        converter: _JsonConverter(),
        interceptors: [_AuthorizationInterceptor()],
      ),
    );
  }

  @Post(path: 'permission/apitoken/')
  Future<Response> getToken(@Body() Map<String, dynamic> body);

  @Get(path: 'permission/systemuser/profile/')
  Future<Response> getSystemUser();

  @Get(path: 'cdr/record/personalized/')
  Future<Response> getPersonalCalls({
    @Query('limit') int limit,
    @Query('offset') int offset,
    @Query('call_date__gt') String from,
    @Query('call_date__lt') String to,
  });

  @Get(path: 'v2/callthrough')
  Future<Response> callthrough({
    @Query('destination') String destination,
  });

  @Put(path: 'v2/password')
  Future<Response> password(@Body() Map<String, dynamic> body);

  @Get(path: 'autologin/token/')
  Future<Response> getAutoLoginToken();

  @Get(path: 'userdestination/')
  Future<Response> getAvailability();

  @Put(path: 'selecteduserdestination/{id}/')
  Future<Response> setAvailability(
    @Path() String id,
    @Body() Map<String, dynamic> body,
  );
}

class _AuthorizationInterceptor implements RequestInterceptor {
  @override
  FutureOr<Request> onRequest(Request request) {
    final authRepository = dependencyLocator<AuthRepository>();

    final user = authRepository.currentUser;

    if (user != null) {
      final authorization = Uri.parse(request.url).path.endsWith('callthrough')
          ? 'Bearer ${user.token}'
          : 'Token ${user.email}:${user.token}';

      return request.copyWith(
        headers: Map.of(request.headers)
          ..addAll({
            'Authorization': authorization,
          }),
      );
    } else {
      return request;
    }
  }
}

class _JsonConverter extends JsonConverter {
  @override
  Response decodeJson<BodyType, InnerType>(Response response) {
    if (response.body == '') {
      return response.copyWith(
        body: <String, dynamic>{},
      );
    }

    return super.decodeJson(response);
  }
}
