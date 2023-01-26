import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../data/models/colltact.dart';
import '../../../../../../domain/colltacts/contact.dart';
import '../../../../../../domain/user_availability/colleagues/colleague.dart';
import '../widget.dart';
import 'avatar.dart';
import 'subtitle.dart';

class ColltactItem extends StatelessWidget {
  final Widget title;
  final Widget subtitle;
  final Widget avatar;
  final VoidCallback onTap;

  static Widget from(Colltact colltact) => colltact.when(
        contact: _ContactItem.new,
        colleague: _ColleagueItem.new,
      );

  ColltactItem._({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: Provider.of<EdgeInsets>(context),
      onTap: onTap,
      leading: avatar,
      title: title,
      subtitle: subtitle,
    );
  }
}

class _ContactItem extends StatelessWidget {
  final Contact contact;

  _ContactItem(this.contact);

  @override
  Widget build(BuildContext context) {
    final colltact = Colltact.contact(contact);

    return ColltactItem._(
      subtitle: ColltactSubtitle(colltact),
      onTap: () => Navigator.pushNamed(
        context,
        ColltactsPageRoutes.details,
        arguments: colltact,
      ),
      title: Text(
        colltact.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      avatar: ColltactAvatar(colltact),
    );
  }
}

class _ColleagueItem extends StatelessWidget {
  final Colleague colleague;

  _ColleagueItem(this.colleague);

  @override
  Widget build(BuildContext context) {
    final colltact = Colltact.colleague(colleague);

    return ColltactItem._(
      title: Text(colleague.name),
      subtitle: ColltactSubtitle(colltact),
      onTap: () => Navigator.pushNamed(
        context,
        ColltactsPageRoutes.details,
        arguments: colltact,
      ),
      avatar: ColltactAvatar(colltact),
    );
  }
}
