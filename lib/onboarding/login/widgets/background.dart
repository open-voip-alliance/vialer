import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../resources/theme.dart';
import '../../../routes.dart';
import '../bloc.dart';

class Background extends StatelessWidget {
  final Widget child;

  const Background({Key key, this.child}) : super(key: key);

  List<Widget> get _clouds => [
        Positioned(
          left: -32,
          top: 32,
          child: _Cloud(),
        ),
        Positioned(
          right: -42,
          top: 136,
          child: _Cloud.mirrored(),
        ),
        Positioned(
          left: -112,
          top: 300,
          child: _Cloud(),
        ),
        Positioned(
          right: -48,
          bottom: 128,
          child: _Cloud(),
        ),
        Positioned(
          left: -48,
          bottom: -16,
          child: _Cloud.mirrored(),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: VialerTheme.gradient,
            ),
          ),
          ..._clouds,
          child,
        ],
      ),
    );
  }
}

class _Cloud extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/background_cloud.svg');
  }

  static Widget mirrored() => Transform.scale(
        scale: -1,
        child: _Cloud(),
      );
}
