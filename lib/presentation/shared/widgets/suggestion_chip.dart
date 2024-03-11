import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SuggestionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onSelected;

  SuggestionChip({
    required this.icon,
    required this.label,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FaIcon(
            icon,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(
            width: 4
          ),
          Text(
            label,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.4),
      shape: StadiumBorder(
        side: BorderSide(
          color: Theme.of(context).primaryColor.withOpacity(0.4),
          width: 0,
        ),
      ),
      onPressed: onSelected,
    );
  }
}
