import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart';

import '../dependency_locator.dart';
import '../domain/authentication/user_was_logged_out.dart';
import '../domain/env.dart';
import '../domain/error_tracking/error_tracking_repository.dart';
import '../domain/event/event_bus.dart';
import '../domain/event/register_event_listeners.dart';
import '../domain/metrics/initialize_metric_collection.dart';
import '../domain/metrics/periodically_identify_for_tracking.dart';
import '../domain/onboarding/apply_onboarding_migration.dart';
import '../domain/onboarding/should_onboard.dart';
import '../domain/remote_logging/enable_console_logging.dart';
import '../domain/remote_logging/enable_remote_logging_if_needed.dart';
import '../domain/user/get_stored_user.dart';
import 'pages/main/business_availability/temporary_redirect/cubit.dart';
import 'pages/main/colltacts/colleagues/cubit.dart';
import 'pages/main/page.dart';
import 'pages/main/widgets/caller/cubit.dart';
import 'pages/main/widgets/caller/widget.dart';
import 'resources/localizations.dart';
import 'resources/theme.dart';
import 'routes.dart';
import 'util/debug.dart';
import 'widgets/brand_provider/widget.dart';
import 'widgets/build_error.dart';
import 'widgets/connectivity_checker/widget.dart';
import 'widgets/missed_call_notification_listener/widget.dart';
import 'widgets/nested_children.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeTimeZones();

  await initializeDependencies();

  ApplyOnboardingMigration()();
  unawaited(InitializeMetricCollection()());
  RegisterDomainEventListenersUseCase()();
  unawaited(EnableConsoleLoggingUseCase()());
  unawaited(EnableRemoteLoggingIfNeededUseCase()());

  final errorTrackingRepository = dependencyLocator<ErrorTrackingRepository>();
  final dsn = dependencyLocator<EnvRepository>().errorTrackingDsn;
  final user = GetStoredUserUseCase()();

  unawaited(PeriodicallyIdentifyForTracking()());

  if (dsn.isEmpty) {
    runApp(const App());
  } else {
    await errorTrackingRepository.run(() => runApp(const App()), dsn, user);
  }
}

class App extends StatefulWidget {
  const App({super.key});

  static void navigateTo(MainPageTab tab) =>
      MainPage.keys.page.currentState!.navigateTo(tab);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  final EventBusObserver _eventBus = dependencyLocator<EventBusObserver>();

  late final bool _shouldOnboard;

  @override
  void initState() {
    super.initState();
    _shouldOnboard = ShouldOnboard()();
    _listenForEvents();
  }

  @override
  Widget build(BuildContext context) {
    return BrandProvider(
      child: Builder(
        builder: (context) {
          return MultiWidgetParent(
            [
              (child) => Caller.create(
                    navigatorKey: _navigatorKey,
                    child: child,
                  ),
              (child) => ConnectivityChecker.create(child: child),
              (child) => MissedCallNotificationPressedListener(
                    onMissedCallNotificationPressed: () =>
                        App.navigateTo(MainPageTab.recents),
                    child: child,
                  ),
              (child) => BlocProvider<TemporaryRedirectCubit>(
                    create: (_) => TemporaryRedirectCubit(),
                    child: child,
                  ),
              (child) => MultiWidgetChildWithDependencies(
                    builder: (context) {
                      return BlocProvider<ColleaguesCubit>(
                        create: (_) => ColleaguesCubit(
                          context.watch<CallerCubit>(),
                        ),
                        child: child,
                      );
                    },
                  ),
            ],
            MaterialApp(
              navigatorKey: _navigatorKey,
              title: context.brand.appName,
              theme: context.brand.theme.themeData,
              initialRoute: _shouldOnboard ? Routes.onboarding : Routes.main,
              routes: Routes.mapped,
              localizationsDelegates: const [
                VialerLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: VialerLocalizations.locales.map(Locale.new),
              builder: (context, child) {
                if (!inDebugMode) {
                  ErrorWidget.builder = (_) => const BuildError();
                }

                return child!;
              },
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

        late Route<dynamic> currentRoute;

        Navigator.popUntil(context, (route) {
          currentRoute = route;
          return route.settings.name == Routes.onboarding;
        });

        // We check if we're already at the onboarding page, otherwise
        // a GlobalKey is used twice. It's possible to be logged out
        // while we're still onboarding. This will happen if the user starts
        // the app but didn't finish onboarding last time.
        if (currentRoute.settings.name == Routes.onboarding) return;

        unawaited(
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.onboarding,
            (r) => false,
          ),
        );
      });
}
