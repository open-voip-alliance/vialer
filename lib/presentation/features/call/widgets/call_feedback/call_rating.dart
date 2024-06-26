import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import 'call_feedback.dart';

class CallRating extends StatelessWidget {
  const CallRating({
    required this.onComplete,
    this.fontSize = 13,
    super.key,
  });

  final void Function(double) onComplete;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return CallFeedbackAlertDialog(
      title: context.msg.main.call.feedback.rating.title,
      semanticsLabel: context.msg.main.call.feedback.rating.semantics.title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar.builder(
            itemPadding: const EdgeInsets.symmetric(
              horizontal: 3,
            ),
            onRatingUpdate: onComplete,
            tapOnlyMode: true,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Icon(
                FontAwesomeIcons.solidStar,
                color: context.brand.theme.colors.primary,
                semanticLabel: switch (index) {
                  0 =>
                    context.msg.main.call.feedback.rating.semantics.firstStar,
                  1 =>
                    context.msg.main.call.feedback.rating.semantics.secondStar,
                  2 =>
                    context.msg.main.call.feedback.rating.semantics.thirdStar,
                  3 =>
                    context.msg.main.call.feedback.rating.semantics.fourthStar,
                  _ =>
                    context.msg.main.call.feedback.rating.semantics.fifthStar,
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 6,
            ),
            child: ExcludeSemantics(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.msg.main.call.feedback.rating.lowerLabel,
                    style: TextStyle(
                      fontSize: fontSize,
                    ),
                  ),
                  Text(
                    context.msg.main.call.feedback.rating.upperLabel,
                    style: TextStyle(
                      fontSize: fontSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
