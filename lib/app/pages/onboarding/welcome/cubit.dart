import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/usecases/get_user.dart';

import 'state.dart';
export 'state.dart';

class WelcomeCubit extends Cubit<WelcomeState> {
  final _getUser = GetUserUseCase();

  WelcomeCubit() : super(WelcomeState()) {
    _emitInitialState();
  }

  Future<void> _emitInitialState() async {
    emit(WelcomeState(user: await _getUser(latest: false)));
  }
}
