import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../domain/repositories/env.dart';
import '../device/repositories/env.dart';

import '../domain/repositories/storage.dart';
import '../data/repositories/storage.dart';

import '../domain/repositories/auth.dart';
import '../data/repositories/auth.dart';

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
  await App._storageRepository.load();

  sentry.run(
    App._authRepository,
    () => runApp(App()),
    dsn: await App._envRepository.sentryDsn,
  );
}

class App extends StatelessWidget {
  static final EnvRepository _envRepository = DeviceEnvRepository();
  static final StorageRepository _storageRepository = DeviceStorageRepository();
  static final AuthRepository _authRepository = DataAuthRepository(
    _storageRepository,
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<EnvRepository>.value(
          value: _envRepository,
        ),
        Provider<StorageRepository>.value(
          value: _storageRepository,
        ),
        Provider<AuthRepository>.value(
          value: _authRepository,
        ),
        Provider<PermissionRepository>(
          create: (_) => DevicePermissionRepository(),
        ),
        Provider<ContactRepository>(
          create: (_) => DeviceContactsRepository(),
        ),
        Provider<RecentCallRepository>(
          create: (_) => DataRecentCallRepository(),
        ),
        Provider<CallRepository>(
          create: (_) => DataCallRepository(),
        ),
        Provider<SettingRepository>(
          create: (_) => DataSettingRepository(_storageRepository),
        ),
        Provider<FeedbackRepository>(
          create: (_) => DataFeedbackRepository(),
        ),
      ],
      child: MaterialApp(
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
      ),
    );
  }
}
