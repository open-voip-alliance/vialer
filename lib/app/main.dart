import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart';

import '../domain/entities/brand.dart';

import '../data/repositories/services/voipgrid.dart';

import '../data/repositories/db/moor.dart';

import '../domain/repositories/env.dart';
import '../device/repositories/env.dart';

import '../domain/repositories/storage.dart';
import '../data/repositories/storage.dart';

import '../domain/repositories/auth.dart';
import '../data/repositories/auth.dart';

import '../domain/repositories/logging.dart';
import '../data/repositories/logging.dart';

import '../domain/repositories/permission.dart';
import '../device/repositories/permission.dart';

import '../domain/repositories/contact.dart';
import '../device/repositories/contact.dart';

import '../domain/repositories/recent_call.dart';
import '../data/repositories/recent_call.dart';

import '../domain/repositories/call.dart';
import '../data/repositories/call.dart';

import '../domain/repositories/setting.dart';
import '../data/repositories/setting.dart';

import '../domain/repositories/feedback.dart';
import '../data/repositories/feedback.dart';

import 'resources/localizations.dart';
import 'resources/theme.dart';
import 'routes.dart';

import 'sentry.dart' as sentry;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeTimeZones();

  final brand = Voys();

  final envRepo = DeviceEnvRepository();

  final storageRepo = DeviceStorageRepository();
  await storageRepo.load();

  final authRepo = DataAuthRepository(storageRepo, brand);

  final settingRepo = DataSettingRepository(storageRepo);

  final loggingRepo = DataLoggingRepository(
    authRepo,
    storageRepo,
    settingRepo,
  );

  loggingRepo.enableConsoleLogging();
  loggingRepo.enableRemoteLoggingIfSettingEnabled();

  final app = App(
    brand: brand,
    service: authRepo.service,
    envRepository: envRepo,
    storageRepository: storageRepo,
    authRepository: authRepo,
    settingRepository: settingRepo,
    loggingRepository: loggingRepo,
  );

  sentry.run(
    authRepo,
    () => runApp(app),
    dsn: await envRepo.sentryDsn,
  );
}

class App extends StatelessWidget {
  final Brand brand;

  final VoipgridService service;

  final EnvRepository envRepository;
  final StorageRepository storageRepository;
  final AuthRepository authRepository;
  final SettingRepository settingRepository;
  final LoggingRepository loggingRepository;

  App({
    Key key,
    @required this.brand,
    @required this.service,
    @required this.envRepository,
    @required this.storageRepository,
    @required this.authRepository,
    @required this.settingRepository,
    @required this.loggingRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<VoipgridService>.value(
          value: service,
        ),
        Provider<Database>(
          create: (_) => Database(),
        ),
        Provider<EnvRepository>.value(
          value: envRepository,
        ),
        Provider<StorageRepository>.value(
          value: storageRepository,
        ),
        Provider<AuthRepository>.value(
          value: authRepository,
        ),
        Provider<LoggingRepository>.value(
          value: loggingRepository,
        ),
        Provider<PermissionRepository>(
          create: (_) => DevicePermissionRepository(),
        ),
        Provider<ContactRepository>(
          create: (_) => DeviceContactsRepository(),
        ),
        Provider<RecentCallRepository>(
          create: (context) => DataRecentCallRepository(
            service,
            Provider.of<Database>(context, listen: false),
            Provider.of<ContactRepository>(context, listen: false),
          ),
        ),
        Provider<CallRepository>(
          create: (_) => DataCallRepository(service),
        ),
        Provider<SettingRepository>.value(
          value: settingRepository,
        ),
        Provider<FeedbackRepository>(
          create: (_) => DataFeedbackRepository(),
        ),
        Provider<Brand>.value(
          value: brand,
        ),
        Provider<BrandTheme>(
          create: (_) => brand is Vialer ? VialerTheme() : VoysTheme(),
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
