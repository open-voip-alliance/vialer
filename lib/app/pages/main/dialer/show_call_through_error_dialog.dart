import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../domain/entities/call_through_exception.dart';

import 'confirm/page.dart';

import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';

Future<void> showCallThroughErrorDialog(
  BuildContext context,
  CallThroughException exception,
) {
  String message;
  if (exception is InvalidDestinationException ||
      exception is NormalizationException) {
    message = context.msg.main.callThrough.error.invalidDestination;
  } else {
    message = context.msg.main.callThrough.error.unknown;
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      final title = Text(context.msg.main.callThrough.error.title);
      final content = SingleChildScrollView(
        child: Text(message),
      );

      final buttonText = context.msg.generic.button.ok;
      void buttonOnPressed() {
        Navigator.pop(context);
        // Also pop the confirm if it's there
        Navigator.popUntil(context, (route) => route is! ConfirmPageRoute);
      }

      if (context.isIOS) {
        return CupertinoAlertDialog(
          title: title,
          content: content,
          actions: <Widget>[
            CupertinoButton(
              onPressed: buttonOnPressed,
              child: Text(buttonText),
            )
          ],
        );
      } else {
        return AlertDialog(
          title: title,
          content: content,
          actions: <Widget>[
            FlatButton(
              onPressed: buttonOnPressed,
              child: Text(
                buttonText.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              splashColor: Theme.of(context).primaryColorLight,
            ),
          ],
        );
      }
    },
  );
}
