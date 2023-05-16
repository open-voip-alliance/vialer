import 'package:flutter/cupertino.dart';
import '../../../../../../resources/theme.dart';

class AvailabilityHeader extends StatelessWidget {
  const AvailabilityHeader(
    this.text, {
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.brand.theme.colors.availabilityHeader,
          ),
        ),
      ),
    );
  }
}
