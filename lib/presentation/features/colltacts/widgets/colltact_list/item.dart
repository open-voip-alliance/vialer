import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:search_highlight_text/search_highlight_text.dart';
import 'package:vialer/presentation/util/phone_number.dart';

import '../../../../../../data/models/colltacts/colltact.dart';
import '../../../../../../data/models/colltacts/contact.dart';
import '../../../../../../data/models/colltacts/shared_contacts/shared_contact.dart';
import '../../../../../../data/models/relations/colleagues/colleague.dart';
import 'avatar.dart';
import 'subtitle.dart';
import 'widget.dart';

class ColltactItem extends StatelessWidget {
  const ColltactItem._({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.avatar,
  });

  final Widget title;
  final Widget subtitle;
  final Widget avatar;
  final VoidCallback onTap;

  static Widget from(Colltact colltact, {bool colleaguesUpToDate = true}) =>
      colltact.when(
        contact: _ContactItem.new,
        colleague: (colleague) => _ColleagueItem(
          colleague,
          colleaguesUpToDate: colleaguesUpToDate,
        ),
        sharedContact: _SharedContactItem.new,
      );

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
  const _ContactItem(this.contact);

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final colltact = Colltact.contact(contact);

    return ColltactItem._(
      title: PhoneNumberText(
        child: SearchHighlightText(
          colltact.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: colltact.name,
      ),
      subtitle: ColltactSubtitle(colltact),
      onTap: () => unawaited(
        Navigator.pushNamed(
          context,
          ColltactsPageRoutes.details,
          arguments: colltact,
        ),
      ),
      avatar: ColltactAvatar(colltact),
    );
  }
}

class _ColleagueItem extends StatelessWidget {
  const _ColleagueItem(this.colleague, {this.colleaguesUpToDate = true});

  final Colleague colleague;
  final bool colleaguesUpToDate;

  @override
  Widget build(BuildContext context) {
    final colltact = Colltact.colleague(colleague);

    return ColltactItem._(
      title: PhoneNumberText(
        child: SearchHighlightText(colleague.name),
        content: colleague.name,
      ),
      subtitle: ColltactSubtitle(
        colltact,
        colleaguesUpToDate: colleaguesUpToDate,
      ),
      onTap: () => unawaited(
        Navigator.pushNamed(
          context,
          ColltactsPageRoutes.details,
          arguments: colltact,
        ),
      ),
      avatar: ColltactAvatar(
        colltact,
        colleaguesUpToDate: colleaguesUpToDate,
      ),
    );
  }
}

class _SharedContactItem extends StatelessWidget {
  const _SharedContactItem(this.sharedContact);

  final SharedContact sharedContact;

  @override
  Widget build(BuildContext context) {
    final colltact = Colltact.sharedContact(sharedContact);

    return ColltactItem._(
      subtitle: ColltactSubtitle(colltact),
      onTap: () => unawaited(
        Navigator.pushNamed(
          context,
          ColltactsPageRoutes.details,
          arguments: colltact,
        ),
      ),
      title: SearchHighlightText(
        colltact.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      avatar: ColltactAvatar(colltact),
    );
  }
}
