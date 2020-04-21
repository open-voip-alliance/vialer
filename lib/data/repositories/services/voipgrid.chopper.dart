// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voipgrid.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$VoipgridService extends VoipgridService {
  _$VoipgridService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = VoipgridService;

  @override
  Future<Response<dynamic>> getToken(Map<String, dynamic> body) {
    final $url = '/api/permission/apitoken/';
    final $body = body;
    final $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getSystemUser() {
    final $url = '/api/permission/systemuser/profile/';
    final $request = Request('GET', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> getPersonalCalls(
      {int limit, int offset, String from, String to}) {
    final $url = '/api/cdr/record/personalized/';
    final $params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      'call_date__gt': from,
      'call_date__lt': to
    };
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> callthrough({String destination}) {
    final $url = '/api/v2/callthrough';
    final $params = <String, dynamic>{'destination': destination};
    final $request = Request('GET', $url, client.baseUrl, parameters: $params);
    return client.send<dynamic, dynamic>($request);
  }
}
