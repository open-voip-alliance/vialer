import 'package:flutter/material.dart';

import '../../../../../domain/entities/contact.dart';

import '../page.dart';

import 'subtitle.dart';
import 'avatar.dart';

class ContactItem extends StatelessWidget {
  final Contact contact;

  const ContactItem({Key key, @required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => Navigator.pushNamed(
        context,
        ContactsPageRoutes.details,
        arguments: contact,
      ),
      leading: ContactAvatar(contact),
      title: Text(contact.name ?? contact.phoneNumbers.first),
      subtitle: ContactSubtitle(contact),
    );
  }
}
