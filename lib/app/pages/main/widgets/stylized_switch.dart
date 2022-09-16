import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../resources/theme.dart';

class StylizedSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const StylizedSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

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
