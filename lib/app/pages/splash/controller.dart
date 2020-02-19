import 'package:flutter/widgets.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../data/repositories/auth_repository.dart';

import '../../routes.dart';
import 'presenter.dart';

class SplashController extends Controller {
  final SplashPresenter _presenter = SplashPresenter(DataAuthRepository());

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
          pageBuilder: (_, __, ___) => Routes.mapped[Routes.onboarding](null),
        ),
      );
    }
  }

  @override
  void initListeners() {
    _presenter.getAuthStatusOnNext = _getAuthStatusOnNext;
  }
}
