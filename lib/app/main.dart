import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart';

import '../dependency_locator.dart';
import 'pages/main/widgets/caller/widget.dart';
import 'resources/localizations.dart';
import 'routes.dart';
import 'sentry.dart' as sentry;
import 'util/brand.dart';
import 'widgets/brand_provider/widget.dart';
import 'widgets/connectivity_checker/widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeTimeZones();

  await initializeDependencies();

  await sentry.run(() => runApp(const App()));
}

class App extends StatelessWidget {
  static final _navigatorKey = GlobalKey<NavigatorState>();

  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BrandProvider(
      child: Builder(
        builder: (context) {
          return Caller.create(
            navigatorKey: _navigatorKey,
            child: ConnectivityChecker(
              child: MaterialApp(
                navigatorKey: _navigatorKey,
                title: context.brand.appName,
                theme: context.brand.theme.themeData,
                initialRoute: Routes.root,
                routes: Routes.mapped,
                localizationsDelegates: [
                  VialerLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: [
                  const Locale('en'),
                  const Locale('nl'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
