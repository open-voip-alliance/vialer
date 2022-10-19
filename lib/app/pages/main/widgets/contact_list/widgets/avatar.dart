import 'package:flutter/material.dart';

import '../../../../../../domain/contacts/contact.dart';
import '../../../../../util/contact.dart';
import '../../../widgets/avatar.dart';
import '../util/color.dart';

class ContactAvatar extends StatelessWidget {
  static const defaultSize = Avatar.defaultSize;

  final Contact contact;
  final double size;

  const ContactAvatar(
    this.contact, {
    Key? key,
    this.size = defaultSize,
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
