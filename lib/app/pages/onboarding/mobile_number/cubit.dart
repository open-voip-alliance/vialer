import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecases/change_mobile_number.dart';
import '../../../../domain/usecases/get_mobile_number.dart';

import 'state.dart';
export 'state.dart';

class MobileNumberCubit extends Cubit<MobileNumberState> {
  final _getMobileNumber = GetMobileNumberUseCase();
  final _changeMobileNumber = ChangeMobileNumberUseCase();

  MobileNumberCubit() : super(MobileNumberState(mobileNumber: null)) {
    _loadMobileNumber();
  }

  void _loadMobileNumber() async {
    emit(
      state.copyWith(
        mobileNumber: await _getMobileNumber(),
      ),
    );
  }

  void changeMobileNumber(String mobileNumber) async {
    final success = await _changeMobileNumber(mobileNumber: mobileNumber);

    emit(
      success
          ? MobileNumberChanged(mobileNumber: mobileNumber)
          : MobileNumberNotChanged(mobileNumber: mobileNumber),
    );
  }
}
