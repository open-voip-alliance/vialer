import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vialer/domain/business_insights/feature_announcements/feature_announcements_repository.dart';
import 'package:vialer/domain/calling/dnd/dnd_repository.dart';
import 'package:vialer/domain/calling/dnd/dnd_service.dart';
import 'package:vialer/domain/user/settings/settings_repository.dart';

import 'app/util/debug.dart';
import 'domain/authentication/authentication_repository.dart';
import 'domain/business_availability/business_availability_repository.dart';
import 'domain/business_availability/business_availability_service.dart';
import 'domain/business_insights/feature_announcements/feature_announcements_service.dart';
import 'domain/call_records/client/database/client_calls.dart';
import 'domain/call_records/client/local_client_calls.dart';
import 'domain/call_records/client/remote_client_calls.dart';
import 'domain/call_records/personal/recent_call_repository.dart';
import 'domain/calling/call_through/call_through.dart';
import 'domain/calling/middleware/middleware_service.dart';
import 'domain/calling/outgoing_number/outgoing_numbers.dart';
import 'domain/calling/voip/client_voip_config_repository.dart';
import 'domain/calling/voip/destination_repository.dart';
import 'domain/calling/voip/app_account_repository.dart';
import 'domain/calling/voip/voip.dart';
import 'domain/colltacts/contact_populator.dart';
import 'domain/colltacts/contact_repository.dart';
import 'domain/colltacts/shared_contacts/shared_contacts_repository.dart';
import 'domain/colltacts/shared_contacts/shared_contacts_service.dart';
import 'domain/env.dart';
import 'domain/error_tracking/error_tracking_repository.dart';
import 'domain/event/event_bus.dart';
import 'domain/feedback/feedback.dart';
import 'domain/legacy/memory_storage_repository.dart';
import 'domain/legacy/storage.dart';
import 'domain/metrics/metrics.dart';
import 'domain/onboarding/country_repository.dart';
import 'domain/openings_hours_basic/opening_hours_repository.dart';
import 'domain/openings_hours_basic/opening_hours_service.dart';
import 'domain/relations/colleagues/colleagues_repository.dart';
import 'domain/relations/websocket/relations_web_socket.dart';
import 'domain/remote_logging/logging.dart';
import 'domain/user/connectivity/connectivity.dart';
import 'domain/user/info/build_info_repository.dart';
import 'domain/user/info/operating_system_info_repository.dart';
import 'domain/user/permissions/permission_repository.dart';
import 'domain/voicemail/voicemail_account_repository.dart';
import 'domain/voipgrid/user_permissions.dart';
import 'domain/voipgrid/voipgrid_api_resource_collector.dart';
import 'domain/voipgrid/voipgrid_service.dart';

final dependencyLocator = GetIt.instance;

/// Pass `ui: false` to skip dependencies that are only used for the UI.
Future<void> initializeDependencies({bool ui = true}) async {
  dependencyLocator
    ..registerSingleton<ErrorTrackingRepository>(ErrorTrackingRepository())
    ..registerSingleton<EventBus>(StreamController.broadcast())
    ..registerSingleton<EventBusObserver>(dependencyLocator<EventBus>().stream)
    ..registerSingleton<VoipgridService>(
      VoipgridService.create(),
    )
    ..registerSingleton<SharedContactsService>(
      SharedContactsService.create(),
    )
    ..registerSingleton<ClientCallsDatabase>(ClientCallsDatabase())
    ..registerSingletonAsync<SharedPreferences>(
      () => SharedPreferences.getInstance(),
    )
    ..registerSingletonWithDependencies<StorageRepository>(
      () => StorageRepository(dependencyLocator<SharedPreferences>()),
      dependsOn: [SharedPreferences],
    )
    ..registerSingletonWithDependencies<SettingsRepository>(
      () => SettingsRepository(dependencyLocator<SharedPreferences>()),
      dependsOn: [SharedPreferences],
    )
    ..registerSingletonWithDependencies<ClientVoipConfigRepository>(
      () => ClientVoipConfigRepository(dependencyLocator<VoipgridService>()),
      dependsOn: [StorageRepository],
    )
    ..registerSingletonAsync<MiddlewareService>(
      MiddlewareService.create,
      dependsOn: [StorageRepository, ClientVoipConfigRepository],
    )
    ..registerFactory<VoipgridApiResourceCollector>(
      VoipgridApiResourceCollector.new,
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
      ..registerSingleton<ContactRepository>(ContactRepository())
      ..registerSingleton<SharedContactsRepository>(
        SharedContactsRepository(
          dependencyLocator<SharedContactsService>(),
          dependencyLocator<VoipgridApiResourceCollector>(),
        ),
      )
      ..registerSingletonWithDependencies<ColleaguesRepository>(
        () => ColleaguesRepository(
          dependencyLocator<VoipgridService>(),
          dependencyLocator<VoipgridApiResourceCollector>(),
          dependencyLocator<StorageRepository>(),
        ),
        dependsOn: [StorageRepository],
      )
      ..registerSingleton<RelationsWebSocket>(RelationsWebSocket());
  }

  dependencyLocator
    ..registerSingletonAsync<EnvRepository>(() async {
      final env = EnvRepository();
      await env.load();
      return env;
    })
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
    ..registerSingletonWithDependencies<UserPermissionsRepository>(
      () => UserPermissionsRepository(
        dependencyLocator<VoipgridService>(),
        dependencyLocator<StorageRepository>(),
      ),
      dependsOn: [StorageRepository],
    )
    ..registerSingleton<VoicemailAccountsRepository>(
      VoicemailAccountsRepository(
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
      dependsOn: [MiddlewareService, EnvRepository],
    )
    ..registerSingletonWithDependencies<AppAccountRepository>(
      () => AppAccountRepository(dependencyLocator<VoipgridService>()),
      dependsOn: [StorageRepository],
    )
    ..registerSingleton<CountryRepository>(CountryRepository())
    ..registerSingleton<MetricsRepository>(
      inDebugMode
          ? ConsoleLoggingMetricsRepository()
          : SegmentMetricsRepository(),
    )
    ..registerSingleton<BusinessAvailabilityRepository>(
      BusinessAvailabilityRepository(BusinessAvailabilityService.create()),
    )
    ..registerSingleton<OpeningHoursRepository>(
      OpeningHoursRepository(OpeningHoursService.create()),
    )
    ..registerSingleton<FeatureAnnouncementsRepository>(
      FeatureAnnouncementsRepository(FeatureAnnouncementsService.create()),
    )
    ..registerSingleton<DndRepository>(
      DndRepository(DndService.create()),
    );

  await dependencyLocator.allReady();
}
