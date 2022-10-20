import 'package:flutter/material.dart';

import '../../../../../domain/entities/availability.dart';
import '../../../../../domain/entities/user.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/stylized_txt.dart';
import 'tile.dart';

class AvailabilityTile extends StatelessWidget {
  final Availability availability;
  final UserAvailabilityType userAvailabilityType;
  final User user;
  final Widget child;

  const AvailabilityTile({
    required this.availability,
    required this.userAvailabilityType,
    required this.user,
    required this.child,
  });

  bool get _shouldDisplayNoAppAccountWarning =>
      availability.findAppAccountFor(user: user) == null;

  bool get _shouldDisplayAvailabilityInfo =>
      (userAvailabilityType == UserAvailabilityType.elsewhere ||
          userAvailabilityType == UserAvailabilityType.notAvailable) &&
      availability.phoneAccounts.isNotEmpty;

  String _text(BuildContext context) {
    var info = _createInfo(
      [
        user.email,
        availability.internalNumber.toString(),
      ],
      separator: ' - ',
    );

    info = '($info)';

    if (userAvailabilityType == UserAvailabilityType.elsewhere) {
      return context.msg.main.settings.list.calling.availability.elsewhere
          .description(info);
    } else if (userAvailabilityType == UserAvailabilityType.notAvailable) {
      return context.msg.main.settings.list.calling.availability.notAvailable
          .description(info, _accountInfoText(availability));
    } else {
      return '';
    }
  }

  String _accountInfoText(Availability availability) {
    final account = availability.findAppAccountFor(user: user) ??
        availability.phoneAccounts.first;

    return _createInfo([
      account.internalNumber.toString(),
      account.description,
    ]);
  }

  String _sharedText(BuildContext context, Availability availability) =>
      context.msg.main.settings.list.calling.availability.resume(
        _accountInfoText(availability),
      );

  /// Create a string based on the given items, separated with a slash.
  ///
  /// e.g. voipAccount1 / 556
  String _createInfo(List<String> items, {String separator = ' / '}) =>
      items.map((e) => e.trim()).join(separator);

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      description: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_shouldDisplayNoAppAccountWarning) ...{
            Padding(
              padding: const EdgeInsets.only(
                top: 8,
              ),
              child: StyledText(
                context.msg.main.settings.list.calling.availability.noAppAccount
                    .description(context.brand.appName),
                style: TextStyle(
                  color: context.brand.theme.colors.red1,
                ),
              ),
            ),
          } else if (_shouldDisplayAvailabilityInfo) ...[
            Padding(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 8,
              ),
              child: StyledText(
                _text(context),
                style: TextStyle(
                  color: userAvailabilityType.asColor(context),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 4,
              ),
              child: StyledText(
                _sharedText(
                  context,
                  availability,
                ),
                style: TextStyle(
                  color: userAvailabilityType.asColor(context),
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              context.msg.main.settings.list.calling.availability.description,
            ),
          ),
        ],
      ),
      childFillWidth: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
        ],
      ),
    );
  }
}
