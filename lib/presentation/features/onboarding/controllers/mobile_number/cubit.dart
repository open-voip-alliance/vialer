import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/data/models/user/user.dart';

import '../../../../../../data/models/user/settings/call_setting.dart';
import '../../../../../../domain/usecases/phone_numbers/strictly_validate_mobile_phone_number.dart';
import '../../../../../../domain/usecases/user/get_logged_in_user.dart';
import '../../../../../../domain/usecases/user/settings/change_setting.dart';
import 'state.dart';

export 'state.dart';

class MobileNumberCubit extends Cubit<MobileNumberState> {
  late final _validatesPhoneNumber = StrictlyValidateMobilePhoneNumber();

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
