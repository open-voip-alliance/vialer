import 'package:get_it/get_it.dart';

import 'domain/repositories/auth.dart';
import 'domain/repositories/brand.dart';
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
import 'domain/repositories/storage.dart';
import 'domain/repositories/voip.dart';

final dependencyLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  dependencyLocator
    ..registerSingleton<Database>(Database())
    ..registerSingleton<EnvRepository>(EnvRepository())
    ..registerSingletonAsync<StorageRepository>(() async {
      final storageRepository = StorageRepository();
      await storageRepository.load();
      return storageRepository;
    })
    ..registerSingleton<VoipgridService>(VoipgridService.create())
    ..registerSingleton<AuthRepository>(
      AuthRepository(
        dependencyLocator<VoipgridService>(),
      ),
    )
    ..registerSingleton<LoggingRepository>(LoggingRepository())
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
    ..registerSingletonWithDependencies<CallThroughRepository>(
      () => CallThroughRepository(
        dependencyLocator<VoipgridService>(),
        dependencyLocator<StorageRepository>(),
      ),
      dependsOn: [StorageRepository],
    )
    ..registerSingleton<BuildInfoRepository>(BuildInfoRepository())
    ..registerSingleton<FeedbackRepository>(
      FeedbackRepository(),
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
    )
    ..registerSingleton<BrandRepository>(BrandRepository());

  await dependencyLocator.allReady();
}
