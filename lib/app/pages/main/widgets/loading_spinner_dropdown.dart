import 'package:flutter/material.dart';

import '../../../widgets/stylized_dropdown.dart';

class LoadingSpinnerDropdown extends StatelessWidget {
  const LoadingSpinnerDropdown({
    required this.color,
    super.key,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return StylizedDropdown<int>(
      value: 0,
      items: [
        DropdownMenuItem<int>(
          value: 0,
          child: Center(
            child: Container(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: color,
                strokeWidth: 3,
              ),
            ),
          ),
        ),
      ],
      isExpanded: true,
      showIcon: false,
      onChanged: null,
    );
  }
}
