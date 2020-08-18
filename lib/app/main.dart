import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart';

import '../domain/entities/brand.dart';

import '../dependency_locator.dart';
import 'resources/localizations.dart';
import 'resources/theme.dart';
import 'routes.dart';

import 'sentry.dart' as sentry;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeTimeZones();

  initializeDependencies();

  await sentry.run(() => runApp(App()));
}

class App extends StatelessWidget {
  App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BrandTheme>(
          create: (_) => dependencyLocator<Brand>() is Vialer
              ? VialerTheme()
              : VoysTheme(),
        ),
        Provider<Brand>(
          create: (_) => dependencyLocator<Brand>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: Provider.of<Brand>(context).appName,
            theme: context.brandTheme.themeData,
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
        },
      ),
    );
  }
}
