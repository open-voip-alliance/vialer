import 'package:flutter/material.dart';

import '../../../../resources/theme.dart';
import '../../../../resources/localizations.dart';

import '../../../../../domain/entities/contact.dart';

class ContactSubtitle extends StatelessWidget {
  final Contact contact;

  const ContactSubtitle(this.contact, {Key key}) : super(key: key);

  String _text(BuildContext context) {
    final phoneNumbers = contact.phoneNumbers;
    final emails = contact.emails;

    if (phoneNumbers.length == 1 && emails.isEmpty) {
      return phoneNumbers.first.value;
    } else if (phoneNumbers.isEmpty && emails.length == 1) {
      return emails.first.value;
    } else if (phoneNumbers.isEmpty && emails.isEmpty) {
      return context.msg.main.contacts.list.item.noNumber;
    } else {
      String phoneNumbersText, emailsText;
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

  @override
  Widget build(BuildContext context) {
    return Text(
      _text(context),
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: context.brandTheme.grey4),
    );
  }
}
