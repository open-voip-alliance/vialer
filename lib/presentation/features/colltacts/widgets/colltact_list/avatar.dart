import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vialer/presentation/features/colltacts/widgets/colltact_list/util/color.dart';
import 'package:vialer/presentation/resources/theme.dart';
import 'package:vialer/presentation/util/contact.dart';

import '../../../../../../data/models/colltacts/colltact.dart';
import '../../../../../../data/models/colltacts/contact.dart';
import '../../../../../../data/models/colltacts/shared_contacts/shared_contact.dart';
import '../../../../../data/models/relations/colleagues/colleague.dart';
import '../../../../shared/widgets/avatar.dart';

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
      sharedContact: SharedContactAvatar.new,
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

  Future<File?> _loadAvatar() async => contact.avatar;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _loadAvatar(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const CircularProgressIndicator();
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return const SizedBox.shrink();
            } else {
              final avatarFile = snapshot.data;
              return Avatar(
                name: contact.displayName,
                backgroundColor: contact.calculateColor(context),
                image: avatarFile != null ? avatarFile : null,
                size: size,
              );
            }
        }
      },
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

class SharedContactAvatar extends StatelessWidget {
  const SharedContactAvatar(
    this.sharedContact, {
    super.key,
    this.size = ColltactAvatar.defaultSize,
  });

  final SharedContact sharedContact;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Avatar(
      name: sharedContact.simpleDisplayName,
      backgroundColor: sharedContact.calculateColor(context),
      size: size,
    );
  }
}

@freezed
class _AvatarColor with _$AvatarColor {
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

  static const _availableIcon = FontAwesomeIcons.check;
  static const _availableForColleaguesIcon =
      FontAwesomeIcons.arrowRightArrowLeft;
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

    return switch (status) {
      ColleagueAvailabilityStatus.available ||
      ColleagueAvailabilityStatus.availableForColleagues =>
        available,
      ColleagueAvailabilityStatus.doNotDisturb => unavailable,
      ColleagueAvailabilityStatus.busy => busy,
      ColleagueAvailabilityStatus.offline => offline,
      _ => unknown,
    };
  }

  IconData _icon() {
    final context = relevantContext;

    if (context != null) {
      return context.when(
        ringing: () => _ringingIcon,
        inCall: () => _inCallIcon,
      );
    }

    return switch (status) {
      ColleagueAvailabilityStatus.available => _availableIcon,
      ColleagueAvailabilityStatus.availableForColleagues =>
        _availableForColleaguesIcon,
      ColleagueAvailabilityStatus.doNotDisturb => _dndIcon,
      ColleagueAvailabilityStatus.busy => _inCallIcon,
      ColleagueAvailabilityStatus.offline => _unavailableIcon,
      _ => _voipAccountIcon,
    };
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
