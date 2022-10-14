import 'dart:async';

import 'package:get_it/get_it.dart';

import 'app/util/debug.dart';
import 'domain/contact_populator.dart';
import 'domain/events/event_bus.dart';
import 'domain/repositories/auth.dart';
import 'domain/repositories/brand.dart';
import 'domain/repositories/build_info.dart';
import 'domain/repositories/business_availability_repository.dart';
import 'domain/repositories/call_through.dart';
import 'domain/repositories/connectivity.dart';
import 'domain/repositories/contact.dart';
import 'domain/repositories/country.dart';
import 'domain/repositories/database/client_calls.dart';
import 'domain/repositories/destination.dart';
import 'domain/repositories/env.dart';
import 'domain/repositories/error_tracking_repository.dart';
import 'domain/repositories/feedback.dart';
import 'domain/repositories/legacy_storage_repository.dart';
import 'domain/repositories/local_client_calls.dart';
import 'domain/repositories/logging.dart';
import 'domain/repositories/memory_storage_repository.dart';
import 'domain/repositories/metrics.dart';
import 'domain/repositories/operating_system_info.dart';
import 'domain/repositories/outgoing_numbers.dart';
import 'domain/repositories/permission.dart';
import 'domain/repositories/recent_call.dart';
import 'domain/repositories/remote_client_calls.dart';
import 'domain/repositories/server_config.dart';
import 'domain/repositories/services/business_availability.dart';
import 'domain/repositories/services/middleware.dart';
import 'domain/repositories/services/voipgrid.dart';
import 'domain/repositories/storage.dart';
import 'domain/repositories/user_permissions.dart';
import 'domain/repositories/voicemail_repository.dart';
import 'domain/repositories/voip.dart';
import 'domain/repositories/voip_config.dart';

final dependencyLocator = GetIt.instance;

/// Pass `ui: false` to skip dependencies that are only used for the UI.
Future<void> initializeDependencies({bool ui = true}) async {
  dependencyLocator
    ..registerSingleton<BrandRepository>(BrandRepository())
    ..registerSingleton<ErrorTrackingRepository>(ErrorTrackingRepository())
    ..registerSingleton<EventBus>(StreamController.broadcast())
    ..registerSingleton<EventBusObserver>(dependencyLocator<EventBus>().stream)
    ..registerSingleton<VoipgridService>(
      VoipgridService.create(),
    )
    ..registerSingleton<ClientCallsDatabase>(ClientCallsDatabase())
    ..registerSingletonAsync<StorageRepository>(() async {
      final storageRepository = StorageRepository();
      await storageRepository.load();
      return storageRepository;
    })
    ..registerSingletonAsync<LegacyStorageRepository>(() async {
      final legacyStorageRepository = LegacyStorageRepository();
      await legacyStorageRepository.load();
      return legacyStorageRepository;
    })
    ..registerSingletonWithDependencies<ServerConfigRepository>(
      () => ServerConfigRepository(
        dependencyLocator<VoipgridService>(),
      ),
      dependsOn: [StorageRepository],
    )
    ..registerSingletonAsync<MiddlewareService>(
      () async => await MiddlewareService.create(),
      dependsOn: [StorageRepository, ServerConfigRepository],
    );

  if (ui) {
    dependencyLocator
      ..registerSingleton<RecentCallRepository>(
        RecentCallRepository(
          dependencyLocator<VoipgridService>(),
        ),
      )
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
    ..registerSingleton<LocalClientCallsRepository>(
      LocalClientCallsRepository(dependencyLocator<ClientCallsDatabase>()),
    )
    ..registerSingleton<RemoteClientCallsRepository>(
      RemoteClientCallsRepository(
        dependencyLocator<VoipgridService>(),
      ),
    )
    ..registerSingleton(
      CallRecordContactPopulator(dependencyLocator<ContactRepository>()),
    )
    ..registerSingleton<UserPermissionsRepository>(
      UserPermissionsRepository(
        dependencyLocator<VoipgridService>(),
      ),
    )
    ..registerSingleton<VoicemailRepository>(
      VoicemailRepository(
        dependencyLocator<VoipgridService>(),
      ),
    )
    ..registerSingleton<LoggingRepository>(LoggingRepository())
    ..registerSingleton<PermissionRepository>(PermissionRepository())
    ..registerSingleton<MemoryStorageRepository>(MemoryStorageRepository())
    ..registerSingletonWithDependencies<CallThroughRepository>(
      () => CallThroughRepository(
        dependencyLocator<VoipgridService>(),
      ),
      dependsOn: [StorageRepository],
    )
    ..registerSingletonWithDependencies<OutgoingNumbersRepository>(
      () => OutgoingNumbersRepository(
        dependencyLocator<VoipgridService>(),
      ),
      dependsOn: [StorageRepository],
    )
    ..registerSingleton<BuildInfoRepository>(BuildInfoRepository())
    ..registerSingleton<OperatingSystemInfoRepository>(
      OperatingSystemInfoRepository(),
    )
    ..registerSingletonWithDependencies<VoipRepository>(
      VoipRepository.new,
      dependsOn: [MiddlewareService],
    )
    ..registerSingletonWithDependencies<VoipConfigRepository>(
      () => VoipConfigRepository(
        dependencyLocator<VoipgridService>(),
      ),
      dependsOn: [StorageRepository],
    )
    ..registerSingleton<CountryRepository>(CountryRepository())
    ..registerSingleton<MetricsRepository>(
      inDebugMode
          ? ConsoleLoggingMetricsRepository()
          : SegmentMetricsRepository(),
    )
    ..registerSingleton<BusinessAvailabilityRepository>(
      BusinessAvailabilityRepository(
        BusinessAvailabilityService.create(),
      ),
    );

  await dependencyLocator.allReady();
}
