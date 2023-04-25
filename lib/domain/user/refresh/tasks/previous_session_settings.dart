// ignore_for_file: avoid_types_on_closure_parameters

import '../../../../dependency_locator.dart';
import '../../../legacy/storage.dart';
import '../../settings/settings.dart';
import '../../user.dart';
import '../user_refresh_task_performer.dart';

/// Restores any settings that we want to maintain across sessions (i.e. when
/// a user logs out). The main example is maintaining the user's remote logging
/// choice, so we can continue to get remote logs when they log back in.
class RefreshPreviousSessionSettings extends SettingsRefreshTaskPerformer {
  StorageRepository get _storageRepository =>
      dependencyLocator<StorageRepository>();

  const RefreshPreviousSessionSettings();

  @override
  Future<SettingsMutator> performSettingsRefreshTask(User _) async {
    final previousSessionSettings = _storageRepository.previousSessionSettings;

    // We clear it after use, so it doesn't override settings in the future.
    _storageRepository.previousSessionSettings = null;

    return (Settings settings) => settings.copyFrom(previousSessionSettings);
  }

  @override
  bool shouldRun(User user) =>
      !_storageRepository.previousSessionSettings.isEmpty;
}
