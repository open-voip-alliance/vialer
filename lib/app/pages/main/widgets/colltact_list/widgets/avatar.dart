import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../../data/models/colltact.dart';
import '../../../../../../domain/colltacts/contact.dart';
import '../../../../../../domain/user_availability/colleagues/colleague.dart';
import '../../../../../resources/theme.dart';
import '../../../../../util/contact.dart';
import '../../../widgets/avatar.dart';
import '../util/color.dart';

part 'avatar.freezed.dart';

class ColltactAvatar extends StatelessWidget {
  static const defaultSize = Avatar.defaultSize;

  final Colltact colltact;
  final double size;

  const ColltactAvatar(
    this.colltact, {
    Key? key,
    this.size = defaultSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return colltact.when(
      colleague: ColleagueAvatar.new,
      contact: ContactAvatar.new,
    );
  }
}

class ContactAvatar extends StatelessWidget {
  final Contact contact;
  final double size;

  const ContactAvatar(
    this.contact, {
    Key? key,
    this.size = ColltactAvatar.defaultSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Avatar(
      name: contact.displayName,
      backgroundColor: contact.calculateColor(context),
      image: contact.avatar,
      size: size,
    );
  }
}

class ColleagueAvatar extends StatelessWidget {
  final Colleague colleague;
  final double size;

  const ColleagueAvatar(
    this.colleague, {
    Key? key,
    this.size = ColltactAvatar.defaultSize,
  }) : super(key: key);

  _AvatarColor _color(BuildContext context) {
    final colors = context.brand.theme.colors;
    final relevantContext = colleague.mostRelevantContext;

    final busy = _AvatarColor(
      foreground: colors.userAvailabilityBusyAccent,
      background: colors.userAvailabilityBusy,
    );
    final available = _AvatarColor(
      foreground: colors.userAvailabilityAvailableAccent,
      background: colors.userAvailabilityAvailable,
    );
    final unavailable = _AvatarColor(
      foreground: colors.userAvailabilityUnavailableAccent,
      background: colors.userAvailabilityUnavailable,
    );
    final unknown = _AvatarColor(
      foreground: colors.userAvailabilityUnknownAccent,
      background: colors.userAvailabilityUnknown,
    );

    if (relevantContext != null) {
      return relevantContext.when(
        ringing: () => busy,
        inCall: () => busy,
      );
    }

    return colleague.map(
      (colleague) {
        switch (colleague.status) {
          case ColleagueAvailabilityStatus.available:
            return available;
          case ColleagueAvailabilityStatus.doNotDisturb:
            return unavailable;
          case ColleagueAvailabilityStatus.busy:
            return busy;
          default:
            return colleague.isAvailableOnMobileAppOrFixedDestination
                ? available
                : unknown;
        }
      },
      unconnectedVoipAccount: (_) => unknown,
    );
  }

  IconData _icon() {
    final context = colleague.mostRelevantContext;

    if (context != null) {
      return context.when(
        ringing: () => FontAwesomeIcons.bell,
        inCall: () => FontAwesomeIcons.phoneVolume,
      );
    }

    return colleague.map(
      (colleague) {
        switch (colleague.status) {
          case ColleagueAvailabilityStatus.available:
            return FontAwesomeIcons.wifi;
          case ColleagueAvailabilityStatus.doNotDisturb:
            return FontAwesomeIcons.bellSlash;
          case ColleagueAvailabilityStatus.busy:
            return FontAwesomeIcons.phoneVolume;
          case ColleagueAvailabilityStatus.unknown:
            return colleague.isAvailableOnMobileAppOrFixedDestination
                ? FontAwesomeIcons.wifi
                : FontAwesomeIcons.wifiSlash;
          case ColleagueAvailabilityStatus.offline:
            return FontAwesomeIcons.wifiSlash;
          default:
            return FontAwesomeIcons.phoneOffice;
        }
      },
      unconnectedVoipAccount: (_) => FontAwesomeIcons.phoneOffice,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);

    return Container(
      width: size,
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: CircleAvatar(
          backgroundColor: color.background,
          foregroundColor: color.foreground,
          child: FaIcon(_icon(), size: size / 2.5),
        ),
      ),
    );
  }
}

@freezed
class _AvatarColor with _$_AvatarColor {
  const factory _AvatarColor({
    required Color foreground,
    required Color background,
  }) = __AvatarColor;
}
