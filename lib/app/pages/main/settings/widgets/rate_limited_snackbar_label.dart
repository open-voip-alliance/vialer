import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';

class RateLimitedSnackbarLabel extends StatefulWidget {
  final DateTime expiresAt;

  const RateLimitedSnackbarLabel({Key? key, required this.expiresAt})
      : super(key: key);

  @override
  _RateLimitedSnackbarLabelState createState() =>
      _RateLimitedSnackbarLabelState();
}

class _RateLimitedSnackbarLabelState extends State<RateLimitedSnackbarLabel> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final remainingSeconds =
        widget.expiresAt.difference(DateTime.now()).inSeconds;

    return Text(
      context.msg.rateLimiting.snackbar.message(
        context.brand.appName,
        remainingSeconds > 0 ? remainingSeconds.toString() : '0',
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
