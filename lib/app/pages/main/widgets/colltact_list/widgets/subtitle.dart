import 'package:flutter/material.dart';

import '../../../../../../data/models/colltact.dart';
import '../../../../../../domain/colltacts/contact.dart';
import '../../../../../../domain/user_availability/colleagues/colleague.dart';
import '../../../../../resources/localizations.dart';
import '../../../../../resources/theme.dart';

class ColltactSubtitle extends StatelessWidget {
  final Colltact colltact;

  const ColltactSubtitle(this.colltact, {Key? key}) : super(key: key);

  String _text(BuildContext context) {
    return colltact.when(
      contact: (contact) => _textForContact(context, contact),
      colleague: (colleague) => _textForColleague(context, colleague),
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

  String _textForColleague(BuildContext context, Colleague colleague) {
    final recentStatus =
        colleague.mostRelevantContextText ?? colleague.availabilityText;

    if (recentStatus == null && colleague.number != null) {
      return colleague.number!;
    } else if (recentStatus != null && colleague.number != null) {
      return '${colleague.number} - $recentStatus';
    } else if (recentStatus != null && colleague.number == null) {
      return '$recentStatus';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _text(context),
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: context.brand.theme.colors.grey4),
    );
  }
}
