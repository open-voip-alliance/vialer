import 'dart:async';

import '../../../../../domain/usecases/calling/outgoing_number/change_outgoing_number.dart';
import '../../../../../presentation/util/loggable.dart';
import '../../../calling/outgoing_number/outgoing_number.dart';
import '../../user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class UpdateOutgoingNumberListener extends SettingChangeListener<OutgoingNumber>
    with Loggable {
  @override
  final key = CallSetting.outgoingNumber;

  @override
  FutureOr<SettingChangeListenResult> applySettingsSideEffects(
    User user,
    OutgoingNumber value,
  ) =>
      changeRemoteValue(
        () async => ChangeOutgoingNumber()(
          value,
          resetDoNotAskAgain: true,
        ),
      );
}
