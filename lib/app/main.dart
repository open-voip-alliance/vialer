import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart';

import '../dependency_locator.dart';
import '../domain/repositories/env.dart';
import '../domain/repositories/error_tracking_repository.dart';
import '../domain/usecases/automatically_login_legacy_user.dart';
import '../domain/usecases/enable_console_logging.dart';
import '../domain/usecases/enable_remote_logging_if_needed.dart';
import 'pages/main/page.dart';
import 'pages/main/widgets/caller/widget.dart';
import 'resources/localizations.dart';
import 'routes.dart';
import 'util/brand.dart';
import 'widgets/brand_provider/widget.dart';
import 'widgets/connectivity_checker/widget.dart';
import 'widgets/missed_call_notification_listener/widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeTimeZones();

  await initializeDependencies();

  EnableConsoleLoggingUseCase()();
  EnableRemoteLoggingIfNeededUseCase()();

  // Check to see if there are user credentials stored from the legacy app,
  // and if there are, automatically import them. This is temporary
  // functionality to allow legacy users to seamlessly switch to this
  // app.
  await AutomaticallyLoginLegacyUser()();

  final errorTrackingRepository = dependencyLocator<ErrorTrackingRepository>();
  final dsn = await dependencyLocator<EnvRepository>().errorTrackingDsn;

  if (dsn.isEmpty) {
    runApp(const App());
  } else {
    await errorTrackingRepository.run(() => runApp(const App()), dsn);
  }
}

class App extends StatelessWidget {
  static final _navigatorKey = GlobalKey<NavigatorState>();

  static final mainPageKey = GlobalKey<MainPageState>();

  const App({Key? key}) : super(key: key);

  static void navigateTo(MainPageTab tab) =>
      mainPageKey.currentState!.navigateTo(tab);

  @override
  Widget build(BuildContext context) {
    return BrandProvider(
      child: Builder(
        builder: (context) {
          return Caller.create(
            navigatorKey: _navigatorKey,
            child: ConnectivityChecker.create(
              child: MissedCallNotificationPressedListener(
                onMissedCallNotificationPressed: () =>
                    navigateTo(MainPageTab.recents),
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
            ),
          );
        },
      ),
    );
  }
}
