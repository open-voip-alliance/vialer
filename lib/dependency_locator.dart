import 'package:get_it/get_it.dart';

import 'domain/entities/brand.dart';
import 'domain/repositories/auth.dart';
import 'domain/repositories/build_info.dart';
import 'domain/repositories/call_through.dart';
import 'domain/repositories/connectivity.dart';
import 'domain/repositories/contact.dart';
import 'domain/repositories/db/database.dart';
import 'domain/repositories/destination.dart';
import 'domain/repositories/env.dart';
import 'domain/repositories/feedback.dart';
import 'domain/repositories/logging.dart';
import 'domain/repositories/metrics.dart';
import 'domain/repositories/permission.dart';
import 'domain/repositories/phone_account.dart';
import 'domain/repositories/recent_call.dart';
import 'domain/repositories/services/voipgrid.dart';
import 'domain/repositories/setting.dart';
import 'domain/repositories/storage.dart';
import 'domain/repositories/voip.dart';

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
      () => SettingRepository(
        dependencyLocator.get<StorageRepository>(),
        dependencyLocator.get<AuthRepository>(),
      ),
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
        dependencyLocator<AuthRepository>(),
      ),
      dependsOn: [StorageRepository],
    )
    ..registerSingletonWithDependencies<CallThroughRepository>(
      () => CallThroughRepository(
        dependencyLocator<VoipgridService>(),
        dependencyLocator<StorageRepository>(),
        dependencyLocator<AuthRepository>(),
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
    )
    ..registerSingleton<ConnectivityRepository>(ConnectivityRepository())
    ..registerSingleton<MetricsRepository>(MetricsRepository())
    ..registerSingletonWithDependencies<DestinationRepository>(
      () => DestinationRepository(
        dependencyLocator<VoipgridService>(),
      ),
      dependsOn: [StorageRepository],
    )
    ..registerSingletonWithDependencies<VoipRepository>(
      () => VoipRepository(),
      dependsOn: [StorageRepository],
    )
    ..registerSingletonWithDependencies<PhoneAccountRepository>(
      () => PhoneAccountRepository(
        dependencyLocator<VoipgridService>(),
      ),
      dependsOn: [StorageRepository],
    );

  await dependencyLocator.allReady();
}
