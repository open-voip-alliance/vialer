import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../resources/localizations.dart';

import '../../../../domain/entities/call_through_exception.dart';

Future<void> showCallThroughErrorDialog(
  BuildContext context,
  CallThroughException exception,
) {
  String message;
  if (exception is InvalidDestinationException) {
    message = context.msg.main.callThrough.error.invalidDestination;
  } else {
    message = context.msg.main.callThrough.error.unknown;
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: Text(context.msg.main.callThrough.error.title),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              context.msg.generic.button.ok.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
            splashColor: Theme.of(context).primaryColorLight,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
