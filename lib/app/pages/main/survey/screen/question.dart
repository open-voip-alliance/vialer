import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/entities/survey/question.dart';
import '../../../../../domain/entities/survey/survey.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/conditional_capitalization.dart';
import '../cubit.dart';

class QuestionScreen extends StatelessWidget {
  final Question question;
  final Survey survey;
  final int answer;

  const QuestionScreen({
    Key key,
    @required this.question,
    @required this.survey,
    this.answer,
  }) : super(key: key);

  void _changeAnswer(BuildContext context, int index) {
    context.read<SurveyCubit>().answerQuestion(index);
  }

  void _previous(BuildContext context) {
    context.read<SurveyCubit>().previous();
  }

  void _next(BuildContext context) {
    context.read<SurveyCubit>().next();
  }

  @override
  Widget build(BuildContext context) {
    final isLastQuestion =
        survey.questions.indexOf(question) == survey.questions.length - 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QuestionHeader(
          index: survey.questions.indexOf(question),
          total: survey.questions.length,
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Text(
            question.phrase,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: question.answers
                .mapIndexed(
                  (index, phrase) => Expanded(
                    child: _Choice(
                      selected: index == answer,
                      beforeSelected: index < (answer ?? -1),
                      extreme:
                          index == 0 || index == question.answers.length - 1,
                      hasSelection: answer != null,
                      onPressed: () => _changeAnswer(context, index),
                      value: Text((index + 1).toString()),
                      label: Text(phrase),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FlatButton(
              onPressed: survey.questions.indexOf(question) != 0
                  ? () => _previous(context)
                  : null,
              textColor: context.brandTheme.primary,
              child: Text(
                context.msg.generic.button.previous
                    .toUpperCaseIfAndroid(context),
              ),
            ),
            FlatButton(
              onPressed: () => _next(context),
              textColor: context.brandTheme.primary,
              child: Text(
                isLastQuestion
                    ? context.msg.generic.button.done
                        .toUpperCaseIfAndroid(context)
                    : context.msg.generic.button.next
                        .toUpperCaseIfAndroid(context),
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ],
    );
  }
}

class _QuestionHeader extends StatelessWidget {
  final int index;
  final int total;

  const _QuestionHeader({
    Key key,
    @required this.index,
    @required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.brandTheme.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Text(
        context.msg.main.survey.question.title(index + 1, total),
        style: TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  final bool selected;
  final bool beforeSelected;
  final bool extreme;
  final bool hasSelection;

  final VoidCallback onPressed;

  final Widget value;
  final Widget label;

  const _Choice({
    Key key,
    @required this.selected,
    @required this.beforeSelected,
    @required this.extreme,
    @required this.hasSelection,
    @required this.onPressed,
    @required this.value,
    @required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 150);
    const curve = Curves.decelerate;
    final highlighted = selected || beforeSelected;

    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          customBorder: CircleBorder(),
          child: AnimatedContainer(
            duration: duration,
            curve: curve,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: highlighted ? Theme.of(context).primaryColor : null,
              border: Border.all(
                color: highlighted
                    ? context.brandTheme.grey4.withOpacity(0)
                    : context.brandTheme.grey4,
              ),
            ),
            padding: EdgeInsets.all(12),
            child: AnimatedDefaultTextStyle(
              duration: duration,
              curve: curve,
              style: DefaultTextStyle.of(context).style.copyWith(
                    color: highlighted ? Colors.white : null,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
              child: value,
            ),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedOpacity(
          duration: duration,
          curve: curve,
          opacity: (extreme && !hasSelection) || selected ? 1 : 0,
          child: DefaultTextStyle.merge(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
            ),
            child: label,
          ),
        ),
      ],
    );
  }
}
