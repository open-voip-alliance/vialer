import 'package:flutter/material.dart';
import 'package:vialer/presentation/resources/theme.dart';

class GroupHeader extends StatelessWidget {
  const GroupHeader({
    required this.group,
    this.numberOfElements,
    this.padding = const EdgeInsets.only(
      top: 16,
      bottom: 4,
      left: 16,
      right: 16,
    ),
    super.key,
  });

  final String group;
  final int? numberOfElements;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final _groupHeader = Text(
      group,
      style: TextStyle(
        color: context.isIOS
            ? context.brand.theme.colors.grey1
            : context.brand.theme.colors.grey5,
        fontSize: 16,
        fontWeight: context.isIOS ? FontWeight.normal : FontWeight.bold,
      ),
    );

    return Padding(
      padding: padding,
      child: numberOfElements != null
          ? Semantics(
              header: true,
              hint: [group, numberOfElements, "contacts"].join(" "),
              child: ExcludeSemantics(child: _groupHeader),
            )
          : Semantics(
              header: true,
              child: _groupHeader,
            ),
    );
  }
}
