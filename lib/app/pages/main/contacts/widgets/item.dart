import 'package:flutter/material.dart';

import 'package:characters/characters.dart';

import '../../../../resources/theme.dart';
import '../../../../../domain/entities/contact.dart';

import '../../../../resources/localizations.dart';

class ContactItem extends StatelessWidget {
  final Contact contact;

  const ContactItem({Key key, this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _ContactItemAvatar(contact),
      title: Text(contact.name ?? contact.phoneNumbers.first),
      subtitle: _ContactSubtitle(contact),
    );
  }
}

class _ContactItemAvatar extends StatelessWidget {
  final Contact contact;

  const _ContactItemAvatar(this.contact, {Key key}) : super(key: key);

  String get _letters {
    final letters = contact.name.split(' ').map(
          (word) => word.characters.first.toUpperCase(),
        );

    return letters.first + letters.last;
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = contact.avatar != null && contact.avatar.isNotEmpty;

    return Container(
      width: 36,
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: CircleAvatar(
          foregroundColor: Colors.white,
          backgroundColor: VialerColors.grey3,
          backgroundImage: hasAvatar ? MemoryImage(contact.avatar) : null,
          child: !hasAvatar
              ? Text(
                  _letters,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _ContactSubtitle extends StatelessWidget {
  final Contact contact;

  const _ContactSubtitle(this.contact, {Key key}) : super(key: key);

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
      style: TextStyle(color: VialerColors.grey4),
    );
  }
}
