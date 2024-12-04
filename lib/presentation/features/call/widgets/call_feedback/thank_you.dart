import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vialer/presentation/resources/localizations.dart';

import 'call_feedback.dart';

class ThankYou extends StatefulWidget {
  const ThankYou({
    required this.onComplete,
    super.key,
  });

  final VoidCallback onComplete;

  @override
  State<StatefulWidget> createState() => _ThankYouState();
}

class _ThankYouState extends State<ThankYou> {
  @override
  void initState() {
    Timer(const Duration(seconds: 2), widget.onComplete);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CallFeedbackAlertDialog(
      title: context.msg.main.call.feedback.written.title,
      titleAlign: TextAlign.center,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.msg.main.settings.feedback.snackBar,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
