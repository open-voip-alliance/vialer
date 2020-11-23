import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart';

import '../dependency_locator.dart';
import '../domain/entities/brand.dart';
import 'pages/main/widgets/caller/widget.dart';
import 'resources/localizations.dart';
import 'resources/theme.dart';
import 'routes.dart';
import 'sentry.dart' as sentry;
import 'widgets/connectivity_checker/widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeTimeZones();

  await initializeDependencies();

  await sentry.run(() => runApp(App()));
}

class App extends StatelessWidget {
  static final _navigatorKey = GlobalKey<NavigatorState>();

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
          return Caller.create(
            navigatorKey: _navigatorKey,
            child: ConnectivityChecker(
              child: MaterialApp(
                navigatorKey: _navigatorKey,
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
              ),
            ),
          );
        },
      ),
    );
  }
}
