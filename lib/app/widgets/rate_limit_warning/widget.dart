import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../pages/main/util/stylized_snack_bar.dart';
import 'cubit.dart';

class RateLimitWarning extends StatefulWidget {
  final Widget child;

  RateLimitWarning._(this.child);

  static Widget create({
    required Widget child,
  }) {
    return BlocProvider<RateLimitWarningCubit>(
      create: (_) => RateLimitWarningCubit(),
      child: RateLimitWarning._(child),
    );
  }

  @override
  State<StatefulWidget> createState() => _RateLimitWarningState();
}

class _RateLimitWarningState extends State<RateLimitWarning> {
  Timer? _timer;

  void _showSnackBar(BuildContext context, RateLimitWarningState state) {
    if (state is RateLimited) {
      showSnackBar(
        context,
        duration: const Duration(seconds: 60),
        icon: const FaIcon(FontAwesomeIcons.bomb),
        label: Text(
          'Rate limit hit accessing: ${state.url}. '
          'Wait until this dissappears and try again.',
        ),
      );
    }

    if (_timer != null) return;

    _timer = Timer(const Duration(seconds: 60), () {
      ScaffoldMessenger.of(context).clearSnackBars();
      _timer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RateLimitWarningCubit, RateLimitWarningState>(
      listener: _showSnackBar,
      child: widget.child,
    );
  }
}
