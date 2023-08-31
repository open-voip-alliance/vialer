import 'package:vialer/app/util/loggable.dart';
import 'package:vialer/domain/use_case.dart';
import 'package:vialer/domain/user/settings/force_update_settings.dart';

import '../../../dependency_locator.dart';
import '../../legacy/storage.dart';
import '../user.dart';

/// Restores any settings that were preserved via
/// `PreserveCrossSessionSettings`. This will apply these as new settings and
/// will therefore run all associated listeners.
class RestoreCrossSessionSettings extends UseCase with Loggable {
  final _storage = dependencyLocator<StorageRepository>();

  Future<void> call(User user) async =>
      ForceUpdateSettings()(_storage.previousSessionSettings);
}
