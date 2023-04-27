import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../routes.dart';
import 'call_feedback.dart';

class WrittenFeedback extends StatefulWidget {
  const WrittenFeedback({
    required this.onComplete,
    super.key,
  });

  final VoidCallback onComplete;

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
            style: TextButton.styleFrom(
              foregroundColor:
                  context.brand.theme.colors.raisedColoredButtonText,
            ),
            child: Text(
              context.msg.main.call.feedback.written.dismiss.toUpperCase(),
            ),
          ),
          TextButton(
            onPressed: () => unawaited(_feedback(context)),
            style: TextButton.styleFrom(
              foregroundColor:
                  context.brand.theme.colors.raisedColoredButtonText,
            ),
            child: Text(
              context.msg.main.call.feedback.written.button.toUpperCase(),
            ),
          ),
        ],
      ],
      titleAlign: TextAlign.center,
      content: Column(
        mainAxisSize: MainAxisSize.min,
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
