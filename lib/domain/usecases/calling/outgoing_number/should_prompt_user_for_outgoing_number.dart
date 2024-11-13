import 'package:vialer/domain/usecases/use_case.dart';
import 'package:vialer/domain/util/phone_number.dart';
import 'package:vialer/presentation/util/loggable.dart';

import '../../../../../data/repositories/voipgrid/user_permissions.dart';
import '../../../../data/models/user/user.dart';
import '../../../../data/repositories/legacy/storage.dart';
import '../../../../dependency_locator.dart';
import '../../user/get_logged_in_user.dart';

/// A usecase that wraps the logic of determining whether or not to display the
/// outgoing number prompt for a given user and the number they have dialed.
class ShouldPromptUserForOutgoingNumber extends UseCase with Loggable {
  User get _user => GetLoggedInUserUseCase()();
  late final storageRepository = dependencyLocator<StorageRepository>();

  bool call({required String destination}) {
    if (destination.isInternalNumber) {
      _log('internal number');
      return false;
    }

    if (!_user.hasPermission(Permission.canChangeOutgoingNumber)) {
      _log('permissions');
      return false;
    }

    if (_user.client.outgoingNumbers.length < 2) {
      _log('user only has 1 outgoing number');
      return false;
    }

    if (storageRepository.doNotShowOutgoingNumberSelector) {
      _log('user requested to not be asked again');
      return false;
    }

    return true;
  }

  void _log(String reason) => logger.info(
        'Skipping outgoing number prompt due to [$reason].',
      );
}
