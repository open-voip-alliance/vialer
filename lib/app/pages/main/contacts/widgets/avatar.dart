import 'package:flutter/material.dart';

import '../../../../../domain/entities/contact.dart';
import '../../widgets/avatar.dart';
import '../util/color.dart';

class ContactAvatar extends StatelessWidget {
  static const defaultSize = Avatar.defaultSize;

  final Contact contact;
  final double size;

  const ContactAvatar(
    this.contact, {
    Key key,
    this.size = defaultSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Avatar(
      name: contact.name,
      backgroundColor: contact.calculateColor(context),
      image: contact.avatar,
      size: size,
    );
  }
}
