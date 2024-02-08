import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/util/context_extensions.dart';
import 'package:vialer/presentation/util/phone_number.dart';

import '../../../../../../data/models/calling/outgoing_number/outgoing_number.dart';

class OutgoingNumberItem extends StatelessWidget {
  const OutgoingNumberItem({
    required this.item,
    required this.onOutgoingNumberSelected,
    required this.active,
    this.highlight = false,
    this.padding = EdgeInsets.zero,
    this.showIcon = false,
  });

  final OutgoingNumber item;
  final void Function(OutgoingNumber outgoingNumber) onOutgoingNumberSelected;
  final bool active;
  final EdgeInsets padding;
  final bool showIcon;

  /// Whether or not to highlight the row for an active number.
  final bool highlight;

  bool get shouldHighlight => active && highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: shouldHighlight
          ? BoxDecoration(
              color: context.colors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            )
          : null,
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (showIcon)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: shouldHighlight
                          ? null
                          : BoxDecoration(
                              shape: BoxShape.circle,
                              color: active
                                  ? context.colors.primaryLight
                                  : context.colors.userAvailabilityUnknown,
                            ),
                      child: Center(
                        child: FaIcon(
                          item.isSuppressed
                              ? FontAwesomeIcons.eyeSlash
                              : FontAwesomeIcons.simCard,
                          size: 14,
                          color: active
                              ? context.colors.primary
                              : context.colors.grey6,
                        ),
                      ),
                    ),
                  SizedBox(width: 14),
                  Expanded(
                    child: OutgoingNumberInfo(item: item),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => onOutgoingNumberSelected(item),
              icon: FaIcon(
                FontAwesomeIcons.solidPhone,
                size: 16,
                color: context.colors.green1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OutgoingNumberInfo extends StatelessWidget {
  const OutgoingNumberInfo({
    super.key,
    required this.item,
    this.textStyle,
    this.subtitleTextStyle,
  });

  final OutgoingNumber item;
  final TextStyle? textStyle;
  final TextStyle? subtitleTextStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormattedPhoneNumber.outgoingNumber(
          context,
          item,
          style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
        ),
        if (item.isSuppressed || item.hasDescription)
          Text(
            item.isSuppressed
                ? context.msg.main.outgoingCLI.prompt.suppress.description
                : item.descriptionOrEmpty,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: subtitleTextStyle ??
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
      ],
    );
  }
}
