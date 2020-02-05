import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../resources/theme.dart';
import '../../widgets/splash_screen.dart';
import '../../widgets/transparent_status_bar.dart';

class Background extends StatefulWidget {
  final Widget child;

  const Background({Key key, this.child})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background> with TickerProviderStateMixin {
  static const _splashScreenTime = Duration(seconds: 3);

  AnimationController _controller;
  Animation<LinearGradient> _gradientAnimation;
  Animation<Color> _iconColorAnimation;

  List<Animation<double>> _cloudAnimations;

  bool _showForm = false;

  List<Alignment> _cloudAlignments = [
    Alignment(-1.2, -1.05),
    Alignment(1.2, -0.7),
    Alignment(-1.9, -0.2),
    Alignment(1.1, 0.8),
    Alignment(-1.2, 1.1),
  ];

  List<Widget> _clouds;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _cloudAnimations = List.generate(_cloudAlignments.length, (i) {
      return Tween<double>(
        begin: Random().nextDouble() * 1.5 + -4,
        end: 0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.decelerate,
        ),
      );
    });

    _clouds = List.generate(_cloudAlignments.length, (i) {
      return AnimatedBuilder(
        animation: _cloudAnimations[i],
        builder: (_, __) => Align(
          alignment: _cloudAlignments[i].add(
            Alignment(0, _cloudAnimations[i].value),
          ),
          child: i == 2 || i == 5 ? _Cloud.mirrored() : _Cloud(),
        ),
      );
    });

    _gradientAnimation = _LinearGradientTween(
      begin: VialerTheme.splashScreenGradient,
      end: VialerTheme.onboardingGradient,
    ).animate(_controller);

    _iconColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.white.withOpacity(0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.addListener(() {
      if (_controller.isCompleted) {
        setState(() => _showForm = true);
      }
    });

    Future.delayed(_splashScreenTime, () => _controller.forward());
  }

  @override
  Widget build(BuildContext context) {
    return TransparentStatusBar(
      brightness: Brightness.light,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AnimatedBuilder(
            animation: _gradientAnimation,
            builder: (context, _) {
              return SplashScreen(
                gradient: _gradientAnimation.value,
                iconColor: _iconColorAnimation.value,
              );
            },
          ),
          ..._clouds,
          AnimatedOpacity(
            opacity: _showForm ? 1 : 0,
            duration: Duration(seconds: 2),
            child: widget.child,
          )
        ],
      ),
    );
  }
}

class _LinearGradientTween extends Tween<LinearGradient> {
  _LinearGradientTween({
    LinearGradient begin,
    LinearGradient end,
  }) : super(begin: begin, end: end);

  @override
  LinearGradient lerp(double t) => LinearGradient.lerp(begin, end, t);
}

class _Cloud extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/background_cloud.svg',
      height: 96,
    );
  }

  static Widget mirrored() => Transform.scale(
        scale: -1,
        child: _Cloud(),
      );
}
