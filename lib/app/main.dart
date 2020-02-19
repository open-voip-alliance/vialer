import 'package:flutter/material.dart';

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
    );
  }
}
