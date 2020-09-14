import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_is_authenticated.dart';

import 'state.dart';
export 'state.dart';

class SplashCubit extends Cubit<SplashState> {
  final _getIsAuthenticated = GetIsAuthenticatedUseCase();

  SplashCubit() : super(CheckingIsAuthenticated()) {
    _getIsAuthenticated().then(_emitStateBasedOnAuthentication);
  }

  void _emitStateBasedOnAuthentication(bool isAuthenticated) {
    if (isAuthenticated) {
      emit(IsAuthenticated());
    } else {
      emit(IsNotAuthenticated());
    }
  }
}
