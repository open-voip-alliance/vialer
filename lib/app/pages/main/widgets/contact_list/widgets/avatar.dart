import 'package:flutter/material.dart';

import '../../../../../../data/models/colltact.dart';
import '../../../../../../domain/colltacts/contact.dart';
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
      colleague: (colleague) => Avatar(
        name: colleague.name,
        backgroundColor: colleague.calculateColor(context),
        // We don't have an image for colleagues currently, but it will be
        // supported in the future.
        image: null,
        size: size,
      ),
      contact: ContactAvatar.new,
    );
  }
}
