import 'dart:async';

import 'package:chopper/chopper.dart';

part 'remote_logging_service.chopper.dart';

@ChopperApi()
abstract class RemoteLoggingService extends ChopperService {
  static const url = '/api/log/';

  /// This service should only ever be accessed in an isolate, so this is the
  /// only way to create it.
  static RemoteLoggingService createInIsolate(String baseUrl) =>
      _$RemoteLoggingService(
        ChopperClient(
          baseUrl: baseUrl,
          converter: const JsonConverter(),
        ),
      );

  @FactoryConverter(response: null)
  @Post(path: url)
  Future<Response> log({
    @Field('token') required String token,
    @Field('app_id') required String appId,
    @Field('logs') required List<dynamic> logs,
  });
}