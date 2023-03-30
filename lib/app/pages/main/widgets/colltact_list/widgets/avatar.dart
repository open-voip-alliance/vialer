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

  const ColleagueAvatar(
    this.colleague, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserAvatar(
      status: colleague.map(
        (colleague) => colleague.isAvailableOnMobileAppOrFixedDestination
            ? ColleagueAvailabilityStatus.available
            : colleague.status,
        unconnectedVoipAccount: (_) => ColleagueAvailabilityStatus.unknown,
      ),
      relevantContext: colleague.map(
        (colleague) => colleague.mostRelevantContext,
        unconnectedVoipAccount: (_) => null,
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

class UserAvatar extends StatelessWidget {
  final ColleagueContext? relevantContext;
  final ColleagueAvailabilityStatus? status;

  static const _availableIcon = FontAwesomeIcons.user;
  static const _unavailableIcon = FontAwesomeIcons.userSlash;
  static const _ringingIcon = FontAwesomeIcons.bellOn;
  static const _inCallIcon = FontAwesomeIcons.phoneVolume;
  static const _dndIcon = FontAwesomeIcons.bellSlash;
  static const _voipAccountIcon = FontAwesomeIcons.phoneOffice;

  final double size;

  const UserAvatar({
    this.relevantContext,
    this.status,
    this.size = ColltactAvatar.defaultSize,
  });

  _AvatarColor _color(BuildContext context) {
    final colors = context.brand.theme.colors;

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
      return relevantContext!.when(
        ringing: () => busy,
        inCall: () => busy,
      );
    }

    switch (status) {
      case ColleagueAvailabilityStatus.available:
        return available;
      case ColleagueAvailabilityStatus.doNotDisturb:
        return unavailable;
      case ColleagueAvailabilityStatus.busy:
        return busy;
      case ColleagueAvailabilityStatus.unknown:
        return unknown;
      default:
        return unknown;
    }
  }

  IconData _icon() {
    final context = relevantContext;

    if (context != null) {
      return context.when(
        ringing: () => _ringingIcon,
        inCall: () => _inCallIcon,
      );
    }

    switch (status) {
      case ColleagueAvailabilityStatus.available:
        return _availableIcon;
      case ColleagueAvailabilityStatus.doNotDisturb:
        return _dndIcon;
      case ColleagueAvailabilityStatus.busy:
        return _inCallIcon;
      case ColleagueAvailabilityStatus.unknown:
        return _voipAccountIcon;
      case ColleagueAvailabilityStatus.offline:
        return _unavailableIcon;
      default:
        return _voipAccountIcon;
    }
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
