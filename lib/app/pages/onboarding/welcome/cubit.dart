import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/usecases/get_current_user.dart';

import 'state.dart';
export 'state.dart';

class WelcomeCubit extends Cubit<WelcomeState> {
  final _getUser = GetCurrentUserUseCase();

  WelcomeCubit() : super(WelcomeState()) {
    emit(WelcomeState(user: _getUser()));
  }
}
