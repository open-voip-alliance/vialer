import 'package:flutter/material.dart';
import 'package:characters/characters.dart';

import '../../../../../domain/entities/contact.dart';

import '../util/color.dart';

class ContactAvatar extends StatelessWidget {
  static const defaultSize = 36.0;

  final Contact contact;
  final double size;

  const ContactAvatar(
    this.contact, {
    Key key,
    this.size = defaultSize,
  }) : super(key: key);

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
      width: size,
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: CircleAvatar(
          foregroundColor: Colors.white,
          backgroundColor: contact.calculateColor(context),
          backgroundImage: hasAvatar ? MemoryImage(contact.avatar) : null,
          child: !hasAvatar
              ? Text(
                  _letters,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16 * (size / defaultSize),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
