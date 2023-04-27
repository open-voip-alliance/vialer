import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../resources/localizations.dart';
import '../../../../util/conditional_capitalization.dart';
import '../cubit.dart';
import '../widgets/big_header.dart';

class HelpUsScreen extends StatelessWidget {
  const HelpUsScreen({
    required this.dontShowThisAgain,
    super.key,
  });

  final bool dontShowThisAgain;

  void _onDontShowThisAgainChanged(BuildContext context, bool value) {
    context.read<SurveyCubit>().setDontShowThisAgain(value);
  }

  void _dismiss(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _next(BuildContext context) {
    context.read<SurveyCubit>().next();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BigHeader(
          icon: Image.asset('assets/survey/help.png'),
          text: Text(context.msg.main.survey.helpUs.title),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                context.msg.main.survey.helpUs.content(
                  // We don't except the questions length to change after, so we
                  // don't use a BlocBuilder
                  context.read<SurveyCubit>().state.survey!.questions.length,
                ),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: dontShowThisAgain,
                  onChanged: (value) => _onDontShowThisAgainChanged(
                    context,
                    value ?? false,
                  ),
                  activeColor: Theme.of(context).primaryColor,
                ),
                Text(context.msg.main.survey.helpUs.dontAskAgain),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _dismiss(context),
                  child: Text(
                    context.msg.generic.button.noThanks
                        .toUpperCaseIfAndroid(context),
                  ),
                ),
                TextButton(
                  onPressed: () => _next(context),
                  child: Text(
                    context.msg.generic.button.yes
                        .toUpperCaseIfAndroid(context),
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
