import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/domain/phone_numbers/validate_mobile_phone_number.dart';
import 'package:vialer/domain/user/user.dart';

import '../../../../domain/user/get_logged_in_user.dart';
import '../../../../domain/user/settings/call_setting.dart';
import '../../../../domain/user/settings/change_setting.dart';
import 'state.dart';

export 'state.dart';

class MobileNumberCubit extends Cubit<MobileNumberState> {
  late final _validatesPhoneNumber = ValidateMobilePhoneNumber();

  MobileNumberCubit()
      : super(
          MobileNumberState(
            GetLoggedInUserUseCase()().settings.get(CallSetting.mobileNumber),
          ),
        );
  final _changeSetting = ChangeSettingUseCase();

  Future<void> changeMobileNumber(String mobileNumber) async {
    final accepted = mobileNumber == '' ||
        await _changeSetting(CallSetting.mobileNumber, mobileNumber) !=
            SettingChangeResult.failed;

    emit(
      accepted
          ? MobileNumberAccepted(mobileNumber)
          : MobileNumberNotAccepted(mobileNumber),
    );
  }

  Future<void> validate(String mobileNumber) async {
    final isValid = mobileNumber.isNotEmpty
        ? await _validatesPhoneNumber(mobileNumber)
        : true;

    emit(
      isValid
          ? MobileNumberState(mobileNumber)
          : MobileNumberNotAccepted(mobileNumber),
    );
  }
}
