import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/brand.dart';

class CallRating extends StatelessWidget {
  final Function(double) onCallRated;

  CallRating({required this.onCallRated});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 10,
        sigmaY: 10,
      ),
      child: AlertDialog(
        title: Text(
          context.msg.main.call.rate.title,
          textScaleFactor: 0.8,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              RatingBar(
                initialRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                tapOnlyMode: true,
                ratingWidget: RatingWidget(
                  full: Icon(
                    VialerSans.star,
                    color: context.brand.theme.primary,
                  ),
                  half: const SizedBox(),
                  empty: Icon(
                    VialerSans.starOutline,
                    color: context.brand.theme.grey4,
                  ),
                ),
                itemPadding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                ),
                onRatingUpdate: onCallRated,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.msg.main.call.rate.lowerLabel,
                      textScaleFactor: 0.9,
                    ),
                    Text(
                      context.msg.main.call.rate.upperLabel,
                      textScaleFactor: 0.9,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
