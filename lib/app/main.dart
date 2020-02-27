import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'resources/localizations.dart';
import 'resources/theme.dart';
import 'routes.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vialer',
      theme: vialerTheme,
      initialRoute: Routes.root,
      routes: Routes.mapped,
      localizationsDelegates: [
        VialerLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'),
        Locale('nl'),
      ],
    );
  }
}
