import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:vialer/presentation/resources/theme.dart';

class StylizedSwitch extends StatelessWidget {
  const StylizedSwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    if (context.isIOS) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
      );
    } else {
      return Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      );
    }
  }
}
