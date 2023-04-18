import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';

class RateLimitedSnackbarLabel extends StatefulWidget {
  final DateTime expiresAt;

  const RateLimitedSnackbarLabel({required this.expiresAt});

  @override
  _RateLimitedSnackbarLabelState createState() =>
      _RateLimitedSnackbarLabelState();
}

class _RateLimitedSnackbarLabelState extends State<RateLimitedSnackbarLabel> {
  late Timer _timer;
  late int remainingSeconds;

  @override
  void initState() {
    super.initState();

    updateRemainingSeconds() {
      setState(() {
        final remaining = widget.expiresAt.difference(DateTime.now()).inSeconds;
        remainingSeconds = remaining > 0 ? remaining : 0;
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
        remainingSeconds.toString(),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
