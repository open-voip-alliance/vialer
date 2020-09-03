import 'package:get_it/get_it.dart';

import 'domain/entities/brand.dart';

import 'domain/repositories/env.dart';
import 'domain/repositories/storage.dart';
import 'domain/repositories/auth.dart';
import 'domain/repositories/logging.dart';
import 'domain/repositories/permission.dart';
import 'domain/repositories/contact.dart';
import 'domain/repositories/recent_call.dart';
import 'domain/repositories/call.dart';
import 'domain/repositories/setting.dart';
import 'domain/repositories/build_info.dart';
import 'domain/repositories/feedback.dart';

import 'domain/repositories/services/voipgrid.dart';
import 'domain/repositories/db/database.dart';

final dependencyLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  dependencyLocator
    ..registerSingleton<Brand>(Voys())
    ..registerSingleton<Database>(Database())
    ..registerSingleton<EnvRepository>(EnvRepository())
    ..registerSingletonAsync<StorageRepository>(() async {
      final storageRepository = StorageRepository();
      await storageRepository.load();
      return storageRepository;
    })
    ..registerSingletonWithDependencies<AuthRepository>(
      () => AuthRepository(
        dependencyLocator<StorageRepository>(),
        dependencyLocator<Brand>(),
      ),
      dependsOn: [StorageRepository],
    )
    ..registerSingletonWithDependencies<SettingRepository>(
      () => SettingRepository(dependencyLocator.get<StorageRepository>()),
      dependsOn: [StorageRepository],
    )
    ..registerSingletonWithDependencies<LoggingRepository>(
      () => LoggingRepository(
        dependencyLocator<AuthRepository>(),
        dependencyLocator<StorageRepository>(),
        dependencyLocator<EnvRepository>(),
        dependencyLocator<SettingRepository>(),
      )
        ..enableConsoleLogging()
        ..enableRemoteLoggingIfSettingEnabled(),
      dependsOn: [StorageRepository],
    )
    ..registerSingleton<PermissionRepository>(PermissionRepository())
    ..registerSingleton<ContactRepository>(ContactRepository())
    ..registerSingletonWithDependencies<RecentCallRepository>(
      () => RecentCallRepository(
        dependencyLocator<VoipgridService>(),
        dependencyLocator<Database>(),
        dependencyLocator<ContactRepository>(),
        dependencyLocator<PermissionRepository>(),
      ),
      dependsOn: [StorageRepository],
    )
    ..registerSingletonWithDependencies<CallRepository>(
      () => CallRepository(
        dependencyLocator<VoipgridService>(),
        dependencyLocator<StorageRepository>(),
      ),
      dependsOn: [StorageRepository],
    )
    ..registerSingleton<BuildInfoRepository>(
      BuildInfoRepository(dependencyLocator<EnvRepository>()),
    )
    ..registerSingletonWithDependencies<FeedbackRepository>(
      () => FeedbackRepository(
        dependencyLocator<AuthRepository>(),
      ),
      dependsOn: [StorageRepository],
    );

  await dependencyLocator.allReady();
}
