import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/app/pages/main/util/phone_number.dart';
import 'package:vialer/app/resources/localizations.dart';
import 'package:vialer/app/util/context_extensions.dart';

import '../../../../../../domain/user/settings/call_setting.dart';

class OutgoingNumberItem extends StatelessWidget {
  const OutgoingNumberItem({
    required this.item,
    required this.onOutgoingNumberSelected,
    required this.active,
    this.highlight = false,
    this.padding = EdgeInsets.zero,
  });

  final OutgoingNumber item;
  final void Function(OutgoingNumber outgoingNumber) onOutgoingNumberSelected;
  final bool active;
  final EdgeInsets padding;

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormattedPhoneNumber.outgoingNumber(
                          context,
                          item,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (item.isSuppressed)
                          Text(
                            context.msg.main.outgoingCLI.prompt.suppress
                                .description,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                    ),
                          ),
                      ],
                    ),
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
