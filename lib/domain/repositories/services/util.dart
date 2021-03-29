import 'dart:async';

import 'package:chopper/chopper.dart' as chopper;
import 'package:dartx/dartx.dart';

import '../../usecases/get_user.dart';

class AuthorizationInterceptor implements chopper.RequestInterceptor {
  /// Paths that force the use of the legacy
  /// `Token <email>:<token>` method of authorization.
  ///
  /// Any path that does not have a `v2` as a segment in it, will automatically
  /// use the legacy method of authorization and doesn't need to be set here.
  ///
  /// This only needs to be set if a `v2` API uses the legacy auth method, then
  /// you can provide it here.
  ///
  /// Any call that contains one of these paths will use the legacy
  /// way of authentication.
  final List<String> forcedLegacyAuthPaths;

  const AuthorizationInterceptor({this.forcedLegacyAuthPaths = const []});

  @override
  FutureOr<chopper.Request> onRequest(chopper.Request request) async {
    final getUser = GetUserUseCase();
    final user = await getUser(latest: false);

    if (user != null) {
      bool useLegacyAuth;

      if (forcedLegacyAuthPaths.any(request.url.contains)) {
        useLegacyAuth = true;
      } else {
        final pathSegments =
            Uri.parse(request.url).pathSegments.where((s) => s.isNotBlank);

        useLegacyAuth = !pathSegments.any((s) => s == 'v2');
      }

      return request.copyWith(
        headers: Map.of(request.headers)
          ..addAll({
            'Authorization': useLegacyAuth
                ? 'Token ${user.email}:${user.token}'
                : 'Bearer ${user.token}',
          }),
      );
    } else {
      return request;
    }
  }
}

class JsonConverter extends chopper.JsonConverter {
  @override
  chopper.Response decodeJson<BodyType, InnerType>(chopper.Response response) {
    if (response.body == '') {
      return response.copyWith(
        body: <String, dynamic>{},
      );
    }

    return super.decodeJson(response);
  }
}
