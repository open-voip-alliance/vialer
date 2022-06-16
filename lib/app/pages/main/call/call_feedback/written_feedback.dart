import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../routes.dart';
import 'call_feedback.dart';

class WrittenFeedback extends StatefulWidget {
  final VoidCallback onComplete;

  const WrittenFeedback({
    required this.onComplete,
  });

  @override
  State<StatefulWidget> createState() => _WrittenFeedbackState();
}

class _WrittenFeedbackState extends State<WrittenFeedback> {
  bool _submitted = false;

  Future<void> _feedback(BuildContext context) async {
    final sent = await Navigator.pushNamed(
          context,
          Routes.feedback,
        ) as bool? ??
        false;

    setState(() {
      _submitted = sent;

      Timer(const Duration(seconds: 2), widget.onComplete);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CallFeedbackAlertDialog(
      title: context.msg.main.call.feedback.written.title,
      actions: [
        if (!_submitted) ...[
          TextButton(
            onPressed: !_submitted ? widget.onComplete : null,
            child: Text(
              context.msg.main.call.feedback.written.dismiss.toUpperCase(),
            ),
            style: TextButton.styleFrom(
              primary: context.brand.theme.colors.raisedColoredButtonText,
            ),
          ),
          TextButton(
            onPressed: () => _feedback(context),
            child: Text(
              context.msg.main.call.feedback.written.button.toUpperCase(),
            ),
            style: TextButton.styleFrom(
              primary: context.brand.theme.colors.raisedColoredButtonText,
            ),
          ),
        ],
      ],
      titleAlign: TextAlign.center,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _submitted
                ? context.msg.main.settings.feedback.snackBar
                : context.msg.main.call.feedback.written.message,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
