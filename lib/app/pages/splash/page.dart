import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import 'controller.dart';
import '../../widgets/splash_screen.dart';
import '../../widgets/transparent_status_bar.dart';

class SplashPage extends View {
  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends ViewState<SplashPage, SplashController> {
  _SplashPageState() : super(SplashController());

  @override
  Widget buildPage() {
    return TransparentStatusBar(
      key: globalKey,
      brightness: Brightness.light,
      child: SplashScreen(),
    );
  }
}
