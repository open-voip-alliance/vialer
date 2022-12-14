import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/user/get_logged_in_user.dart';
import '../../../../domain/user/settings/call_setting.dart';
import '../../../../domain/user/settings/change_setting.dart';
import 'state.dart';

export 'state.dart';

class MobileNumberCubit extends Cubit<MobileNumberState> {
  final _changeSetting = ChangeSettingUseCase();

  MobileNumberCubit()
      : super(
          MobileNumberState(
            GetLoggedInUserUseCase()().settings.get(CallSetting.mobileNumber),
          ),
        );

  void changeMobileNumber(String mobileNumber) async {
    final accepted = mobileNumber == '' ||
        await _changeSetting(CallSetting.mobileNumber, mobileNumber) !=
            SettingChangeResult.failed;

    emit(
      accepted
          ? MobileNumberAccepted(mobileNumber)
          : MobileNumberNotAccepted(mobileNumber),
    );
  }
}
