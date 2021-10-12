import 'package:flutter/material.dart';

import '../../../../../domain/entities/availability.dart';
import '../../../../../domain/entities/system_user.dart';
import '../../../../resources/localizations.dart';
import '../../../../util/stylized_txt.dart';
import 'tile.dart';

class AvailabilityTile extends StatelessWidget {
  final Availability availability;
  final UserAvailabilityType userAvailabilityType;
  final SystemUser user;
  final Widget child;

  const AvailabilityTile({
    required this.availability,
    required this.userAvailabilityType,
    required this.user,
    required this.child,
  });

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
      label: Text(
        context.msg.main.settings.list.calling.availability.title,
      ),
      description: Text(
        context.msg.main.settings.list.calling.availability.description,
      ),
      childFillWidth: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          if (_shouldDisplayAvailabilityInfo)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 10,
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
                    bottom: 10,
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
            ),
        ],
      ),
    );
  }
}
