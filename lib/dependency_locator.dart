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
import 'domain/repositories/operating_system_info.dart';
import 'domain/repositories/permission.dart';
import 'domain/repositories/recent_call.dart';
import 'domain/repositories/services/middleware.dart';
import 'domain/repositories/services/voipgrid.dart';
import 'domain/repositories/storage.dart';
import 'domain/repositories/voip.dart';
import 'domain/repositories/voip_config.dart';

final dependencyLocator = GetIt.instance;

/// Pass `ui: false` to skip dependencies that are only used for the UI.
Future<void> initializeDependencies({bool ui = true}) async {
  dependencyLocator
    ..registerSingleton<VoipgridService>(
      VoipgridService.create(),
    )
    ..registerSingleton<MiddlewareService>(
      MiddlewareService.create(),
    )
    ..registerSingletonAsync<StorageRepository>(() async {
      final storageRepository = StorageRepository();
      await storageRepository.load();
      return storageRepository;
    });

  if (ui) {
    dependencyLocator
      ..registerSingleton<Database>(Database())
      ..registerSingleton<RecentCallRepository>(
        RecentCallRepository(
          dependencyLocator<VoipgridService>(),
          dependencyLocator<Database>(),
        ),
      )
      ..registerSingleton<MetricsRepository>(MetricsRepository())
      ..registerSingleton<ConnectivityRepository>(ConnectivityRepository())
      ..registerSingletonWithDependencies<DestinationRepository>(
        () => DestinationRepository(
          dependencyLocator<VoipgridService>(),
        ),
        dependsOn: [StorageRepository],
      )
      ..registerSingleton<FeedbackRepository>(FeedbackRepository())
      ..registerSingleton<ContactRepository>(ContactRepository());
  }

  dependencyLocator
    ..registerSingleton<EnvRepository>(EnvRepository())
    ..registerSingleton<AuthRepository>(
      AuthRepository(
        dependencyLocator<VoipgridService>(),
      ),
    )
    ..registerSingleton<LoggingRepository>(LoggingRepository())
    ..registerSingleton<PermissionRepository>(PermissionRepository())
    ..registerSingletonWithDependencies<CallThroughRepository>(
      () => CallThroughRepository(
        dependencyLocator<VoipgridService>(),
      ),
      dependsOn: [StorageRepository],
    )
    ..registerSingleton<BuildInfoRepository>(BuildInfoRepository())
    ..registerSingleton<OperatingSystemInfoRepository>(
      OperatingSystemInfoRepository(),
    )
    ..registerSingleton<VoipRepository>(VoipRepository())
    ..registerSingletonWithDependencies<VoipConfigRepository>(
      () => VoipConfigRepository(
        dependencyLocator<VoipgridService>(),
      ),
      dependsOn: [StorageRepository],
    )
    ..registerSingleton<BrandRepository>(BrandRepository());

  await dependencyLocator.allReady();
}
