import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../domain/user/user.dart';
import '../../../../../../domain/voipgrid/availability.dart';
import '../../../../../../domain/voipgrid/destination.dart';
import '../../../../../../domain/voipgrid/fixed_destination.dart';
import '../../../../../../domain/voipgrid/phone_account.dart';
import '../../../../../../domain/voipgrid/web_page.dart';
import '../../../../../resources/localizations.dart';
import '../../../../../resources/theme.dart';
import '../../../../../util/stylized_txt.dart';
import '../../../../web_view/page.dart';
import '../../cubit.dart';
import 'editable_value.dart';
import 'value.dart';
import 'widget.dart';

class AvailabilityTile extends StatelessWidget {
  final User user;

  final Availability _availability;
  final UserAvailabilityType _userAvailabilityType;

  AvailabilityTile(this.user, {super.key})
      : _availability = user.settings.get(CallSetting.availability),
        _userAvailabilityType = user.availabilityType;

  late final bool _shouldDisplayNoAppAccountWarning =
      _availability.findAppAccountFor(user: user) == null;

  late final bool _shouldDisplayAvailabilityInfo =
      (_userAvailabilityType == UserAvailabilityType.elsewhere ||
              _userAvailabilityType == UserAvailabilityType.notAvailable) &&
          _availability.phoneAccounts.isNotEmpty;

  String _text(BuildContext context) {
    var info = _createInfo(
      [
        user.email,
        _availability.internalNumber.toString(),
      ],
      separator: ' - ',
    );

    info = '($info)';

    if (_userAvailabilityType == UserAvailabilityType.elsewhere) {
      return context.msg.main.settings.list.calling.availability.elsewhere
          .description(info);
    } else if (_userAvailabilityType == UserAvailabilityType.notAvailable) {
      return context.msg.main.settings.list.calling.availability.notAvailable
          .description(info, _accountInfoText);
    } else {
      return '';
    }
  }

  late final String _accountInfoText = () {
    final account = _availability.findAppAccountFor(user: user) ??
        _availability.phoneAccounts.first;

    return _createInfo([
      account.internalNumber.toString(),
      account.description,
    ]);
  }();

  String _sharedText(BuildContext context, Availability availability) =>
      context.msg.main.settings.list.calling.availability
          .resume(_accountInfoText);

  /// Create a string based on the given items, separated with a slash.
  ///
  /// e.g. voipAccount1 / 556
  String _createInfo(List<String> items, {String separator = ' / '}) =>
      items.map((e) => e.trim()).join(separator);

  void _openAddAvailabilityWebView(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewPage(
            WebPage.addDestination,
          ),
        ),
      );

      context.read<SettingsCubit>().refreshAvailability();
    });
  }

  @override
  Widget build(BuildContext context) {
    const key = CallSetting.availability;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SettingTile(
        description: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_shouldDisplayNoAppAccountWarning) ...{
              Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                ),
                child: StyledText(
                  context
                      .msg.main.settings.list.calling.availability.noAppAccount
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
                    color: _userAvailabilityType.asColor(context),
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
                    _availability,
                  ),
                  style: TextStyle(
                    color: _userAvailabilityType.asColor(context),
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
            MultipleChoiceSettingValue<Destination?>(
              value: _availability.activeDestination,
              items: [
                ..._availability.destinations.map(
                  (destination) => DropdownMenuItem<Destination>(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(destination.dropdownValue(context)),
                    ),
                    value: destination,
                  ),
                ),
                DropdownMenuItem<Destination>(
                  child: Text(
                    context.msg.main.settings.list.calling.addAvailability,
                  ),
                  value: null,
                  onTap: () => _openAddAvailabilityWebView(context),
                ),
              ],
              onChanged: (destination) => destination != null
                  ? defaultOnChanged(
                      context,
                      key,
                      _availability.copyWithSelectedDestination(
                        destination: destination,
                      ),
                    )
                  : () {},
              isExpanded: true,
            ),
          ],
        ),
      ),
    );
  }
}

extension AvailabilityType on User {
  UserAvailabilityType get availabilityType {
    final availability = settings.get(CallSetting.availability);

    final selectedDestination = availability.selectedDestinationInfo ?? null;

    if (selectedDestination == null ||
        (selectedDestination.phoneAccountId == null &&
            selectedDestination.fixedDestinationId == null)) {
      return UserAvailabilityType.notAvailable;
    }

    if (selectedDestination.phoneAccountId.toString() == appAccountId) {
      return UserAvailabilityType.available;
    }

    return UserAvailabilityType.elsewhere;
  }
}

enum UserAvailabilityType { available, elsewhere, notAvailable }

extension Display on UserAvailabilityType {
  Color asColor(BuildContext context) {
    if (this == UserAvailabilityType.elsewhere) {
      return context.brand.theme.colors.availableElsewhere;
    } else if (this == UserAvailabilityType.notAvailable) {
      return context.brand.theme.colors.notAvailable;
    } else {
      return context.brand.theme.colors.available;
    }
  }

  Color asAccentColor(BuildContext context) {
    if (this == UserAvailabilityType.elsewhere) {
      return context.brand.theme.colors.availableElsewhereAccent;
    } else if (this == UserAvailabilityType.notAvailable) {
      return context.brand.theme.colors.notAvailableAccent;
    } else {
      return context.brand.theme.colors.availableAccent;
    }
  }
}

extension on Destination {
  String dropdownValue(BuildContext context) {
    final destination = this;

    if (destination == FixedDestination.notAvailable) {
      return context.msg.main.settings.list.calling.notAvailable;
    } else {
      if (destination is FixedDestination) {
        if (destination.phoneNumber == null) {
          return '${destination.description}';
        }

        return '${destination.phoneNumber} / ${destination.description}';
      } else {
        return '${(destination as PhoneAccount).internalNumber} /'
            ' ${destination.description}';
      }
    }
  }
}
