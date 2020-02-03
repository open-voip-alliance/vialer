export 'event.dart';
export 'state.dart';

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../api/api.dart';
import '../../auth/bloc.dart';

import 'event.dart';
import 'state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final Api api;
  final AuthBloc authBloc;

  LoginBloc({@required this.api, @required this.authBloc});

  @override
  LoginState get initialState => NotLoggedIn();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is Login) {
      final tokenResponse = await api.voipgrid.getToken({
        'email': event.username,
        'password': event.password,
      });

      if (tokenResponse.body != null &&
          tokenResponse.body.containsKey('api_token')) {
        final token = tokenResponse.body['api_token'];

        authBloc.add(
          LoggedIn(
            email: event.username,
            token: token,
          ),
        );

        yield LoginSuccessful();
      } else {
        yield LoginFailed();
      }
    }
  }
}
