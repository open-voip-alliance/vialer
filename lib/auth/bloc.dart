export 'event.dart';
export 'state.dart';

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../api/api.dart';
import '../api/system_user.dart';
import '../storage.dart';
import 'event.dart';
import 'state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Api api;

  AuthBloc({@required this.api});

  @override
  AuthState get initialState => Uninitialized();

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    final storage = Storage();
    await storage.load();

    if (event is LoggedIn) {
      api.systemUser = SystemUser(email: event.email);
      api.token = event.token;
      storage.apiToken = event.token;

      final systemUserResponse = await api.voipgrid.getSystemUser();
      api.systemUser = SystemUser.fromJson(systemUserResponse.body);
      storage.systemUser = api.systemUser;

      yield Authenticated();
    }

    if (event is Check) {
      final token = storage.apiToken;

      if (token != null) {
        api.systemUser = storage.systemUser;
        api.token = token;

        yield Authenticated();
      } else {
        yield NotAuthenticated();
      }
    }
  }
}
