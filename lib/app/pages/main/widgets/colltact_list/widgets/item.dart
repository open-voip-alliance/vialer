import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../data/models/colltact.dart';
import '../widget.dart';
import 'avatar.dart';
import 'subtitle.dart';

class ColltactItem extends StatelessWidget {
  final Colltact colltact;

  const ColltactItem({
    Key? key,
    required this.colltact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: Provider.of<EdgeInsets>(context),
      onTap: () => Navigator.pushNamed(
        context,
        ColltactsPageRoutes.details,
        arguments: colltact,
      ),
      leading: ColltactAvatar(colltact),
      title: Text(colltact.name),
      subtitle: ColltactSubtitle(colltact),
    );
  }
}
