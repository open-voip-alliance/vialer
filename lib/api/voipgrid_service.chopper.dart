// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voipgrid_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

class _$VoipGridService extends VoipGridService {
  _$VoipGridService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = VoipGridService;

  @override
  Future<Response> getToken(Map<String, dynamic> body) {
    final $url = 'api/permission/apitoken/';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> getSystemUser() {
    final $url = 'api/permission/systemuser/profile/';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> getPhoneAccount(String accountId) {
    final $url = 'api/phoneaccount/basic/phoneaccount/$accountId/';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response> register(
      {String name,
      String token,
      dynamic sipUserId,
      String osVersion,
      String clientVersion,
      String app,
      String remoteLoggingId}) {
    final $url = 'api/android-device/';
    final $params = <String, dynamic>{
      'name': name,
      'token': token,
      'sip_user_id': sipUserId,
      'os_version': osVersion,
      'client_version': clientVersion,
      'app': app,
      'remote_logging_id': remoteLoggingId
    };
    final $request = Request('POST', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }
}
