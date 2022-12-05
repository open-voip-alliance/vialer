import 'package:flutter/material.dart';

import '../../../../../domain/calling/voip/availability_repository.dart';
import '../../../../../domain/user/user.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/stylized_txt.dart';
import 'tile.dart';

class AvailabilityTile extends StatelessWidget {
  final Destinations destinations;
  final UserAvailabilityType userAvailabilityType;
  final User user;
  final Widget child;

  const AvailabilityTile({
    required this.destinations,
    required this.userAvailabilityType,
    required this.user,
    required this.child,
  });

  bool get _shouldDisplayNoAppAccountWarning =>
      destinations.findAppAccountFor(user: user) == null;

  bool get _shouldDisplayAvailabilityInfo =>
      (userAvailabilityType == UserAvailabilityType.elsewhere ||
          userAvailabilityType == UserAvailabilityType.notAvailable) &&
      destinations.phoneAccounts.isNotEmpty;

  String _text(BuildContext context) {
    var info = _createInfo(
      [
        user.email,
        destinations.internalNumber.toString(),
      ],
      separator: ' - ',
    );

    info = '($info)';

    if (userAvailabilityType == UserAvailabilityType.elsewhere) {
      return context.msg.main.settings.list.calling.availability.elsewhere
          .description(info);
    } else if (userAvailabilityType == UserAvailabilityType.notAvailable) {
      return context.msg.main.settings.list.calling.availability.notAvailable
          .description(info, _accountInfoText(destinations));
    } else {
      return '';
    }
  }

  String _accountInfoText(Destinations destinations) {
    final account = destinations.findAppAccountFor(user: user) ??
        destinations.phoneAccounts.first;

    return _createInfo([
      account.internalNumber.toString(),
      account.description,
    ]);
  }

  String _sharedText(BuildContext context, Destinations destinations) =>
      context.msg.main.settings.list.calling.availability.resume(
        _accountInfoText(destinations),
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
                  destinations,
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
