import 'package:vialer/app/util/loggable.dart';
import 'package:vialer/domain/use_case.dart';

import '../../../dependency_locator.dart';
import '../../legacy/storage.dart';
import '../user.dart';
import 'change_settings.dart';

/// Restores any settings that were preserved via
/// `PreserveCrossSessionSettings`. This will apply these as new settings and
/// will therefore run all associated listeners.
class RestoreCrossSessionSettings extends UseCase with Loggable {
  final _storage = dependencyLocator<StorageRepository>();
  final _changeSettings = ChangeSettingsUseCase();

  Future<void> call(User user) async {
    final settings = _storage.previousSessionSettings;
    _storage.previousSessionSettings = null;

    if (settings.isEmpty) return;

    logger.info('Restoring cross-session settings');

    await _changeSettings(settings, track: false);
  }
}
