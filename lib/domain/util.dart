import 'dart:async';
import 'dart:io';

import 'package:chopper/chopper.dart' as chopper;
import 'package:chopper/chopper.dart';
import 'package:dartx/dartx.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../dependency_locator.dart';
import 'authentication/unauthorized_api_response.dart';
import 'event/event_bus.dart';
import 'user/get_stored_user.dart';
import 'user/user.dart';

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

  /// The user can be passed in directly rather than inferred, this is used
  /// to support creation within an isolate.
  final User? user;

  const AuthorizationInterceptor({
    this.forcedLegacyAuthPaths = const [],
    this.user,
  });

  @override
  FutureOr<chopper.Request> onRequest(chopper.Request request) {
    final user = this.user ?? GetStoredUserUseCase()();

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

/// We want to log out any users if they encounter as 401 response as this
/// suggests that we do not have a valid token, this will fire the appropriate
/// event so action can be taken.
class UnauthorizedResponseInterceptor extends chopper.ResponseInterceptor {
  final List<int> unauthorizedStatusCodes;
  final _eventBus = dependencyLocator<EventBus>();

  UnauthorizedResponseInterceptor({
    this.unauthorizedStatusCodes = const [401],
  });

  @override
  FutureOr<chopper.Response> onResponse(Response<dynamic> response) {
    final statusCode = response.statusCode;

    if (_isUnauthorized(statusCode)) {
      _eventBus.broadcast(UnauthorizedApiResponseEvent(statusCode));
    }

    return response;
  }

  bool _isUnauthorized(int statusCode) =>
      unauthorizedStatusCodes.contains(statusCode);
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

class DatabaseUtils {
  static LazyDatabase openConnection(String filename) {
    return LazyDatabase(() async {
      return NativeDatabase(await databaseFile(filename));
    });
  }

  static LazyDatabase openConnectionForIsolate(String path) {
    return LazyDatabase(() async {
      return NativeDatabase(File(path));
    });
  }

  static Future<File> databaseFile(String filename) async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return File(p.join(dbFolder.path, filename));
  }
}
