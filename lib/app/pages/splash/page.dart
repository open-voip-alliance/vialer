import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../domain/repositories/auth.dart';

import 'controller.dart';
import '../../widgets/splash_screen.dart';
import '../../widgets/transparent_status_bar.dart';

class SplashPage extends View {
  final AuthRepository _authRepository;

  SplashPage(this._authRepository);

  @override
  State<StatefulWidget> createState() => _SplashPageState(_authRepository);
}

class _SplashPageState extends ViewState<SplashPage, SplashController> {
  _SplashPageState(AuthRepository authRepository)
      : super(SplashController(authRepository));

  @override
  Widget buildPage() {
    return TransparentStatusBar(
      key: globalKey,
      brightness: Brightness.light,
      child: SplashScreen(),
    );
  }
}
