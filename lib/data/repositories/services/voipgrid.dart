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
    return _$VoipgridService(
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
}

class _AuthorizationInterceptor implements RequestInterceptor {
  final AuthRepository _authRepository;

  _AuthorizationInterceptor(this._authRepository);

  @override
  FutureOr<Request> onRequest(Request request) {
    final user = _authRepository.currentUser;

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
