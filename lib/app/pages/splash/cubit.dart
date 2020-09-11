import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../routes.dart';
import '../../../domain/usecases/get_is_authenticated.dart';

import 'state.dart';
export 'state.dart';

class SplashScreenCubit extends Cubit<SplashScreenState> {
  final _getIsAuthenticated = GetIsAuthenticatedUseCase();

  SplashScreenCubit() : super(SplashScreenShowing()) {
    
  }
  
  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    _presenter.getAuthStatus();
  }

  void _getIsAuthenticatedOnNext(bool authenticated) {
    if (authenticated) {
      Navigator.pushReplacementNamed(getContext(), Routes.main);
    } else {
      // Push without animation, so the two splash screens appear
      // to be a seamless transition.
      Navigator.pushReplacement(
        getContext(),
        PageRouteBuilder(
          transitionDuration: Duration.zero,
          pageBuilder: (context, _, __) {
            return Routes.mapped[Routes.onboarding](context);
          },
        ),
      );
    }
  }

  @override
  void initListeners() {
    _presenter.getIsAuthenticatedOnNext = _getIsAuthenticatedOnNext;
  }
}
