import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart';

import '../dependency_locator.dart';
import '../domain/events/event_bus.dart';
import '../domain/events/user_was_logged_out.dart';
import '../domain/repositories/env.dart';
import '../domain/repositories/error_tracking_repository.dart';
import '../domain/usecases/automatically_login_legacy_user.dart';
import '../domain/usecases/enable_console_logging.dart';
import '../domain/usecases/enable_remote_logging_if_needed.dart';
import '../domain/usecases/get_is_authenticated.dart';
import '../domain/usecases/get_stored_user.dart';
import '../domain/usecases/initialize_metric_collection.dart';
import '../domain/usecases/register_event_listeners.dart';
import 'pages/main/page.dart';
import 'pages/main/widgets/caller/widget.dart';
import 'resources/localizations.dart';
import 'resources/theme.dart';
import 'routes.dart';
import 'util/debug.dart';
import 'widgets/brand_provider/widget.dart';
import 'widgets/build_error.dart';
import 'widgets/connectivity_checker/widget.dart';
import 'widgets/missed_call_notification_listener/widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeTimeZones();

  await initializeDependencies();

  InitializeMetricCollection()();
  RegisterDomainEventListenersUseCase()();
  EnableConsoleLoggingUseCase()();
  EnableRemoteLoggingIfNeededUseCase()();

  // Check to see if there are user credentials stored from the legacy app,
  // and if there are, automatically import them. This is temporary
  // functionality to allow legacy users to seamlessly switch to this
  // app.
  await AutomaticallyLoginLegacyUser()();

  final errorTrackingRepository = dependencyLocator<ErrorTrackingRepository>();
  final dsn = await dependencyLocator<EnvRepository>().errorTrackingDsn;
  final user = await GetStoredUserUseCase()();

  if (dsn.isEmpty) {
    runApp(const App());
  } else {
    await errorTrackingRepository.run(() => runApp(const App()), dsn, user);
  }
}

class App extends StatefulWidget {
  const App();

  static void navigateTo(MainPageTab tab) =>
      MainPage.keys.page.currentState!.navigateTo(tab);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  final EventBusObserver _eventBus = dependencyLocator<EventBusObserver>();

  late final bool _isAuthenticatedAtAppStart;

  @override
  void initState() {
    super.initState();
    _isAuthenticatedAtAppStart = GetIsAuthenticatedUseCase()();
    _listenForEvents();
  }

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
                    App.navigateTo(MainPageTab.recents),
                child: MaterialApp(
                  navigatorKey: _navigatorKey,
                  title: context.brand.appName,
                  theme: context.brand.theme.themeData,
                  initialRoute: _isAuthenticatedAtAppStart
                      ? Routes.main
                      : Routes.onboarding,
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
                  builder: (context, child) {
                    if (!inDebugMode) {
                      ErrorWidget.builder = (_) => const BuildError();
                    }

                    return child!;
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Listen for any app-level events, these events should require a "global"
  /// response. For example, the user should be forced back to the onboarding
  /// screen whenever they are logged out.
  void _listenForEvents() => _eventBus.on<UserWasLoggedOutEvent>((event) {
        final context = _navigatorKey.currentContext;

        if (context == null) return;

        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.onboarding,
          (r) => false,
        );
      });
}
