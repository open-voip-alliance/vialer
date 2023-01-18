import 'package:flutter/material.dart';
import 'stylized_switch.dart';

class BottomToggle extends StatefulWidget {
  final String name;
  final bool initialValue;
  final Function(bool enabled) onChanged;

  const BottomToggle({
    required this.name,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  BottomToggleState createState() => BottomToggleState(
        initialValue: initialValue,
      );
}

class BottomToggleState extends State<BottomToggle> {
  bool _toggleValue;

  BottomToggleState({required bool initialValue}) : _toggleValue = initialValue;

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
            onChanged: (value) {
              setState(() {
                _toggleValue = value;
                widget.onChanged(value);
              });
            },
          )
        ],
      ),
    );
  }
}
