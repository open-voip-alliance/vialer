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
  const ColltactAvatar(
    this.colltact, {
    super.key,
    this.size = defaultSize,
    this.colleaguesUpToDate = true,
  });

  static const defaultSize = Avatar.defaultSize;

  final Colltact colltact;
  final double size;
  final bool colleaguesUpToDate;

  @override
  Widget build(BuildContext context) {
    return colltact.when(
      colleague: (colleague) => ColleagueAvatar(
        colleague,
        colleaguesUpToDate: colleaguesUpToDate,
      ),
      contact: ContactAvatar.new,
    );
  }
}

class ContactAvatar extends StatelessWidget {
  const ContactAvatar(
    this.contact, {
    super.key,
    this.size = ColltactAvatar.defaultSize,
  });

  final Contact contact;
  final double size;

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
  const ColleagueAvatar(
    this.colleague, {
    super.key,
    this.colleaguesUpToDate = true,
  });

  final Colleague colleague;
  final bool colleaguesUpToDate;

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
  const UserAvatar({
    this.relevantContext,
    this.status,
    this.size = ColltactAvatar.defaultSize,
    super.key,
  });

  final ColleagueContext? relevantContext;
  final ColleagueAvailabilityStatus? status;

  static const _availableIcon = FontAwesomeIcons.user;
  static const _unavailableIcon = FontAwesomeIcons.userSlash;
  static const _ringingIcon = FontAwesomeIcons.bellOn;
  static const _inCallIcon = FontAwesomeIcons.phoneVolume;
  static const _dndIcon = FontAwesomeIcons.bellSlash;
  static const _voipAccountIcon = FontAwesomeIcons.phoneOffice;

  final double size;

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
    final offline = _AvatarColor(
      foreground: colors.userAvailabilityOfflineAccent,
      background: colors.userAvailabilityOffline,
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
      case ColleagueAvailabilityStatus.offline:
        return offline;
      case ColleagueAvailabilityStatus.unknown:
      case null:
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
      case ColleagueAvailabilityStatus.offline:
        return _unavailableIcon;
      case ColleagueAvailabilityStatus.unknown:
      case null:
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
