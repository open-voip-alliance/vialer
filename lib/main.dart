import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'api/api.dart';
import 'auth/bloc.dart';
import 'resources/theme.dart';
import 'routes.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  final _api = Api();

  @override
  Widget build(BuildContext context) {
    return Provider<Api>.value(
      value: _api,
      child: BlocProvider<AuthBloc>(
        create: (BuildContext context) => AuthBloc(
          api: _api,
        ),
        child: MaterialApp(
          title: 'Vialer',
          theme: vialerTheme,
          initialRoute: Routes.root,
          routes: Routes.mapped,
        ),
      ),
    );
  }
}
