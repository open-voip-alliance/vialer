import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../domain/colltacts/contact.dart';
import '../../../../../util/contact.dart';
import '../widget.dart';
import 'avatar.dart';
import 'subtitle.dart';

class ColltactItem extends StatelessWidget {
  final Contact contact; //wip

  const ColltactItem({
    Key? key,
    required this.contact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: Provider.of<EdgeInsets>(context),
      onTap: () => Navigator.pushNamed(
        context,
        ColltactsPageRoutes.details,
        arguments: contact,
      ),
      leading: ContactAvatar(contact),
      title: Text(contact.displayName),
      subtitle: ContactSubtitle(contact),
    );
  }
}
