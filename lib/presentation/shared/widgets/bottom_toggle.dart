import 'package:flutter/material.dart';

import 'stylized_switch.dart';

class BottomToggle extends StatefulWidget {
  const BottomToggle({
    required this.name,
    required this.initialValue,
    required this.onChanged,
    super.key,
  });

  final String name;
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  @override
  BottomToggleState createState() => BottomToggleState();
}

class BottomToggleState extends State<BottomToggle> {
  late bool _toggleValue = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          StylizedSwitch(
            value: _toggleValue,
            onChanged: _onChanged,
          ),
        ],
      ),
    );
  }

  void _onChanged(bool value) {
    setState(() {
      _toggleValue = value;
      widget.onChanged(value);
    });
  }
}
