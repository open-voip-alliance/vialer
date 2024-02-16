import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

class RateLimitedSnackbarLabel extends StatefulWidget {
  const RateLimitedSnackbarLabel({required this.expiresAt, super.key});

  final DateTime expiresAt;

  @override
  State<RateLimitedSnackbarLabel> createState() =>
      _RateLimitedSnackbarLabelState();
}

class _RateLimitedSnackbarLabelState extends State<RateLimitedSnackbarLabel> {
  late Timer _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();

    void updateRemainingSeconds() {
      setState(() {
        final remaining = widget.expiresAt.difference(DateTime.now()).inSeconds;
        _remainingSeconds = remaining > 0 ? remaining : 0;
      });
    }

    updateRemainingSeconds();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => updateRemainingSeconds(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      context.msg.rateLimiting.snackbar.message(
        context.brand.appName,
        _remainingSeconds.toString(),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
