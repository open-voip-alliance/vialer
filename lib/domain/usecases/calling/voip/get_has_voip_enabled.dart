import 'package:vialer/data/models/user/user.dart';

import '../../../../data/models/user/settings/call_setting.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';

class GetHasVoipEnabledUseCase extends UseCase {
  final _getUser = GetLoggedInUserUseCase();

  bool call() {
    final user = _getUser();

    return user.settings.get(CallSetting.useVoip) && user.isAllowedVoipCalling;
  }
}
