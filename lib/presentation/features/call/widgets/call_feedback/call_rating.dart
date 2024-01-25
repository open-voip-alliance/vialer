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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar(
            tapOnlyMode: true,
            ratingWidget: RatingWidget(
              full: FaIcon(
                FontAwesomeIcons.solidStar,
                color: context.brand.theme.colors.primary,
              ),
              half: const SizedBox(),
              empty: Icon(
                FontAwesomeIcons.star,
                color: context.brand.theme.colors.grey4,
              ),
            ),
            itemPadding: const EdgeInsets.symmetric(
              horizontal: 3,
            ),
            onRatingUpdate: onComplete,
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 6,
            ),
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
        ],
      ),
    );
  }
}
