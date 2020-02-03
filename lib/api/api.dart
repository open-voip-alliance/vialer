import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';

import 'system_user.dart';
import 'voipgrid_service.dart';

class Api {
  static const voipgridApiUrl = 'https://partner.voipgrid.nl';

  String _token;

  String get token => _token;

  set token(String value) {
    _token = value;

    _voipgrid = VoipGridService.create(
      ChopperClient(
        baseUrl: voipgridApiUrl,
        converter: JsonConverter(),
        interceptors: [AuthorizationInterceptor(this)],
      ),
    );
  }

  SystemUser systemUser;

  Api() {
    // Some endpoints of the VoIPGrid API are usable without a token,
    // so initialize the service immediately.
    _voipgrid = VoipGridService.create(
      ChopperClient(
        baseUrl: voipgridApiUrl,
        converter: JsonConverter(),
      ),
    );
  }

  VoipGridService _voipgrid;

  VoipGridService get voipgrid => _voipgrid;
}

class AuthorizationInterceptor implements RequestInterceptor {
  final Api api;

  AuthorizationInterceptor(this.api);

  @override
  FutureOr<Request> onRequest(Request request) {
    if (api.token != null) {
      return request.replace(headers: {
        'Authorization': 'Token ${api.systemUser.email}:${api.token}',
      });
    } else {
      return request;
    }
  }
}

extension ApiExtension on BuildContext {
  Api get api => Provider.of<Api>(this, listen: false);
}
