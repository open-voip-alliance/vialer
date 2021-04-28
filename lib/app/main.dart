import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart';

import '../dependency_locator.dart';
import '../domain/repositories/env.dart';
import '../domain/repositories/error_tracking_repository.dart';
import '../domain/usecases/enable_console_logging.dart';
import '../domain/usecases/enable_remote_logging_if_needed.dart';
import 'pages/main/widgets/caller/widget.dart';
import 'resources/localizations.dart';
import 'routes.dart';
import 'util/brand.dart';
import 'widgets/brand_provider/widget.dart';
import 'widgets/connectivity_checker/widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeTimeZones();

  await initializeDependencies();

  EnableConsoleLoggingUseCase()();
  EnableRemoteLoggingIfNeededUseCase()();

  final errorTrackingRepository = dependencyLocator<ErrorTrackingRepository>();
  final dsn = await dependencyLocator<EnvRepository>().errorTrackingDsn;

  if (dsn == null) {
    runApp(const App());
  } else {
    await errorTrackingRepository.run(() => runApp(const App()), dsn);
  }
}

class App extends StatelessWidget {
  static final _navigatorKey = GlobalKey<NavigatorState>();

  const App({Key? key}) : super(key: key);

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
