import 'package:flutter/material.dart';
import 'package:vialer/presentation/util/context_extensions.dart';

import 'package:vialer/presentation/resources/localizations.dart';

class Heading extends StatelessWidget {
  const Heading();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20,
            ),
            child: Center(
              child: Text(
                context.msg.main.outgoingCLI.prompt.title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Divider(
            color: context.colors.grey5,
          ),
        ],
      ),
    );
  }
}

class Subheading extends StatelessWidget {
  const Subheading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(text, style: Theme.of(context).textTheme.titleSmall),
          ),
          SizedBox(height: 4),
        ],
      ),
    );
  }
}
