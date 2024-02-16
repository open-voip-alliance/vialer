import 'package:flutter/material.dart';

import 'package:vialer/presentation/resources/theme.dart';

class Background extends StatelessWidget {
  const Background({
    required this.style,
    required this.child,
    super.key,
  });

  final Style style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        switch (style) {
          Style.triangle => _BackgroundTriangle(),
          Style.split => _BackgroundSplit(),
          Style.cascading => _BackgroundCascading(),
        },
        child,
      ],
    );
  }
}

class _BackgroundTriangle extends StatelessWidget {
  const _BackgroundTriangle();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _BackgroundShape(
          begin: Alignment(0.5, 1.2),
          end: Alignment(-.8, 0),
          startColor: context.brand.theme.colors.primaryLight,
          endColor: Colors.white,
        ),
        _BackgroundShape(
          begin: Alignment(1.2, -1),
          end: Alignment(-.5, .4),
          startColor: context.brand.theme.colors.primary,
        ),
      ],
    );
  }
}

class _BackgroundSplit extends StatelessWidget {
  const _BackgroundSplit();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _BackgroundShape(
          begin: Alignment(0.5, 0.6),
          end: Alignment(-.8, .2),
          startColor: context.brand.theme.colors.primaryLight,
          endColor: Colors.white,
        ),
        _BackgroundShape(
          begin: Alignment.topRight,
          end: Alignment(-1.0, 2.2),
          startColor: context.brand.theme.colors.primary,
        ),
      ],
    );
  }
}

class _BackgroundCascading extends StatelessWidget {
  const _BackgroundCascading();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _BackgroundShape(
          begin: Alignment(-1.2, -.2),
          end: Alignment(.5, .3),
          startColor: context.brand.theme.colors.primaryLight,
          endColor: Colors.white,
        ),
        _BackgroundShape(
          begin: Alignment(-1.7, -1.1),
          end: Alignment(.4, -.5),
          startColor: context.brand.theme.colors.primary,
          endColor: Colors.transparent,
        ),
      ],
    );
  }
}

class _BackgroundShape extends StatelessWidget {
  const _BackgroundShape({
    required this.begin,
    required this.end,
    required this.startColor,
    this.endColor = Colors.transparent,
  });

  final Alignment begin;
  final Alignment end;
  final Color startColor;
  final Color endColor;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: [.5, .5],
            begin: begin,
            end: end,
            colors: [
              startColor,
              endColor,
            ],
          ),
        ),
      ),
    );
  }
}

enum Style {
  triangle,
  split,
  cascading,
}
