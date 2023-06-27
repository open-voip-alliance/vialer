import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:vialer/app/pages/main/util/phone_number.dart';

import '../../../../../../data/models/colltact.dart';
import '../../../../../../domain/colltacts/contact.dart';
import '../../../../../../domain/user_availability/colleagues/colleague.dart';
import '../../../../../resources/localizations.dart';
import '../../../../../resources/theme.dart';

class ColltactSubtitle extends StatelessWidget {
  const ColltactSubtitle(
    this.colltact, {
    super.key,
    this.colleaguesUpToDate = true,
  });

  final Colltact colltact;
  final bool colleaguesUpToDate;

  String _text(BuildContext context) {
    return colltact.when(
      contact: (contact) => _textForContact(context, contact),
      colleague: (colleague) => _textForColleague(
        context,
        colleague,
        colleaguesUpToDate,
      ),
    );
  }

  String _textForContact(BuildContext context, Contact contact) {
    final phoneNumbers = contact.phoneNumbers;
    final emails = contact.emails;

    if (phoneNumbers.length == 1 && emails.isEmpty) {
      return phoneNumbers.first.value;
    } else if (phoneNumbers.isEmpty && emails.length == 1) {
      return emails.first.value;
    } else if (phoneNumbers.isEmpty && emails.isEmpty) {
      return context.msg.main.contacts.list.item.noNumber;
    } else {
      String? phoneNumbersText, emailsText;
      if (phoneNumbers.isNotEmpty) {
        phoneNumbersText = context.msg.main.contacts.list.item.numbers(
          phoneNumbers.length,
        );
      }

      if (emails.isNotEmpty) {
        emailsText = context.msg.main.contacts.list.item.emails(
          emails.length,
        );
      }

      if (phoneNumbersText != null && emailsText == null) {
        return phoneNumbersText;
      } else if (phoneNumbersText == null && emailsText != null) {
        return emailsText;
      } else {
        return '$phoneNumbersText & $emailsText';
      }
    }
  }

  String _textForColleague(
    BuildContext context,
    Colleague colleague,
    bool colleaguesUpToDate,
  ) {
    final recentStatus = colleaguesUpToDate
        ? colleague.mostRelevantContextText(context) ??
            colleague.availabilityText(context)
        : context.msg.main.colleagues.status.notUpToDate;

    if (recentStatus == null && colleague.number != null) {
      return colleague.number!;
    } else if (recentStatus != null && colleague.number != null) {
      return '${colleague.number} - $recentStatus';
    } else if (recentStatus != null && colleague.number == null) {
      return recentStatus;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PhoneNumberText(
      Text(
        _text(context),
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: context.brand.theme.colors.grey4),
      ),
    );
  }
}

extension on Colleague {
  String? mostRelevantContextText(BuildContext context) => map(
        (colleague) => colleague.context.firstOrNull?.text(context),
        unconnectedVoipAccount: (_) => null,
      );

  String? availabilityText(BuildContext context) => map(
        (colleague) => colleague.isAvailableOnMobileAppOrFixedDestination
            ? context.msg.main.colleagues.status.available
            : colleague.status?.text(context),
        unconnectedVoipAccount: (_) => null,
      );
}

extension on ColleagueContext {
  String text(BuildContext context) => when(
        ringing: () => context.msg.main.colleagues.context.ringing,
        inCall: () => context.msg.main.colleagues.context.inCall,
      );
}

extension on ColleagueAvailabilityStatus {
  String text(BuildContext context) {
    switch (this) {
      case ColleagueAvailabilityStatus.doNotDisturb:
        return context.msg.main.colleagues.status.doNotDisturb;
      case ColleagueAvailabilityStatus.offline:
        return context.msg.main.colleagues.status.offline;
      case ColleagueAvailabilityStatus.available:
        return context.msg.main.colleagues.status.available;
      case ColleagueAvailabilityStatus.busy:
        return context.msg.main.colleagues.status.busy;
      case ColleagueAvailabilityStatus.unknown:
        return context.msg.main.colleagues.status.unknown;
    }
  }
}
