import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../domain/repositories/auth.dart';

import '../../routes.dart';
import 'presenter.dart';

class SplashController extends Controller {
  final SplashPresenter _presenter;

  SplashController(AuthRepository authRepository)
      : _presenter = SplashPresenter(authRepository);

  @override
  void initController(GlobalKey<State<StatefulWidget>> key) {
    super.initController(key);

    _presenter.getAuthStatus();
  }

  void _getAuthStatusOnNext(bool authenticated) {
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
    _presenter.getAuthStatusOnNext = _getAuthStatusOnNext;
  }
}
