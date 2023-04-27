import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../domain/calling/voip/destination.dart';
import '../../../../../../domain/user/settings/call_setting.dart';
import '../../../../../../domain/user/user.dart';
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
  AvailabilityTile({
    required this.user,
    required this.destinations,
    this.userNumber,
    this.enabled = true,
    super.key,
  }) : _userAvailabilityType = user.availabilityType;
  final User user;
  final int? userNumber;
  final List<Destination> destinations;
  final bool enabled;

  final UserAvailabilityType _userAvailabilityType;

  late final bool _shouldDisplayNoAppAccountWarning =
      !user.isAllowedVoipCalling;

  late final bool _shouldDisplayAvailabilityInfo =
      (_userAvailabilityType == UserAvailabilityType.elsewhere ||
              _userAvailabilityType == UserAvailabilityType.notAvailable) &&
          destinations.phoneAccounts.isNotEmpty;

  String _text(BuildContext context) {
    var info = _createInfo(
      [
        user.email,
        userNumber.toString(),
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
    final account = destinations.findAppAccountFor(user: user) ??
        destinations.phoneAccounts.first;

    return _createInfo([
      account.internalNumber.toString(),
      account.description,
    ]);
  }();

  String _sharedText(BuildContext context) =>
      context.msg.main.settings.list.calling.availability
          .resume(_accountInfoText);

  /// Create a string based on the given items, separated with a slash.
  ///
  /// e.g. voipAccount1 / 556
  String _createInfo(List<String> items, {String separator = ' / '}) =>
      items.map((e) => e.trim()).join(separator);

  void _openAddAvailabilityWebView(BuildContext context) {
    final settings = context.read<SettingsCubit>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await WebViewPage.open(context, to: WebPage.addDestination);
      unawaited(settings.refreshAvailability());
    });
  }

  @override
  Widget build(BuildContext context) {
    const key = CallSetting.destination;

    const helpTextSize = 13.5;

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
                  fontSize: helpTextSize,
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
                  fontSize: helpTextSize,
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
                ),
                style: TextStyle(
                  color: _userAvailabilityType.asColor(context),
                  fontSize: 13,
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              context.msg.main.settings.list.calling.availability.description,
              style: const TextStyle(
                fontSize: helpTextSize,
              ),
            ),
          ),
        ],
      ),
      childFillWidth: true,
      child: Column(
        children: [
          MultipleChoiceSettingValue<Destination?>(
            value: user.settings.getOrNull(CallSetting.destination),
            padding: EdgeInsets.zero,
            items: [
              ...destinations.map(
                (destination) => DropdownMenuItem<Destination>(
                  value: destination,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(destination.dropdownValue(context)),
                  ),
                ),
              ),
              DropdownMenuItem<Destination>(
                onTap: () => _openAddAvailabilityWebView(context),
                child: Text(
                  context.msg.main.settings.list.calling.addAvailability,
                ),
              ),
            ],
            onChanged: enabled
                ? (destination) => destination != null
                    ? unawaited(
                        defaultOnChanged(
                          context,
                          key,
                          destination,
                        ),
                      )
                    : () {}
                : null,
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}

extension AvailabilityType on User {
  UserAvailabilityType get availabilityType {
    final user = this;
    final destination = user.settings.getOrNull(CallSetting.destination);

    if (destination == null) {
      return UserAvailabilityType.notAvailable;
    }

    return destination.when(
      unknown: () => UserAvailabilityType.unknown,
      notAvailable: () => UserAvailabilityType.notAvailable,
      phoneAccount: (id, _, __, ___) => id.toString() == user.appAccountId
          ? UserAvailabilityType.available
          : UserAvailabilityType.elsewhere,
      phoneNumber: (_, __, ___) => UserAvailabilityType.elsewhere,
    );
  }
}

enum UserAvailabilityType { available, elsewhere, notAvailable, unknown }

extension Display on UserAvailabilityType {
  Color asColor(BuildContext context) {
    if (this == UserAvailabilityType.elsewhere) {
      return context.brand.theme.colors.availableElsewhere;
    } else if (this == UserAvailabilityType.notAvailable) {
      return context.brand.theme.colors.notAvailable;
    } else {
      return context.brand.theme.colors.userAvailabilityAvailableAccent;
    }
  }

  Color asAccentColor(BuildContext context) {
    if (this == UserAvailabilityType.elsewhere) {
      return context.brand.theme.colors.availableElsewhereAccent;
    } else if (this == UserAvailabilityType.notAvailable) {
      return context.brand.theme.colors.notAvailableAccent;
    } else {
      return context.brand.theme.colors.userAvailabilityAvailable;
    }
  }
}

extension on Destination {
  String dropdownValue(BuildContext context) {
    final destination = this;

    return destination.when(
      unknown: () => context.msg.main.settings.list.calling.unknown,
      notAvailable: () => context.msg.main.settings.list.calling.notAvailable,
      phoneNumber: (_, description, phoneNumber) =>
          phoneNumber == null ? '$description' : '$phoneNumber / $description',
      phoneAccount: (_, description, __, internalNumber) =>
          '$internalNumber / $description',
    );
  }
}
