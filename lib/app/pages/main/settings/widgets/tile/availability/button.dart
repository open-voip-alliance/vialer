import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../../resources/theme.dart';

class AvailabilityButton extends StatelessWidget {
  const AvailabilityButton({
    required this.text,
    this.leadingIcon,
    this.trailingIcon,
    this.onPressed,
    this.isActive = true,
    super.key,
  });

  final VoidCallback? onPressed;
  final bool isActive;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isActive
            ? context.brand.theme.colors.userAvailabilityAvailable
            : context.brand.theme.colors.userAvailabilityUnknown,
        foregroundColor: isActive
            ? context.brand.theme.colors.userAvailabilityAvailableAccent
            : context.brand.theme.colors.userAvailabilityUnknownAccent,
        disabledBackgroundColor: isActive
            ? context.brand.theme.colors.userAvailabilityAvailable
            : context.brand.theme.colors.userAvailabilityUnknown,
        disabledForegroundColor: isActive
            ? context.brand.theme.colors.userAvailabilityAvailableAccent
            : context.brand.theme.colors.userAvailabilityUnknownAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  if (leadingIcon != null) ...[
                    SizedBox(
                      width: 18,
                      child: Center(
                        child: FaIcon(
                          leadingIcon,
                          size: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      text.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingIcon != null)
              FaIcon(
                trailingIcon,
                size: 14,
              ),
          ],
        ),
      ),
    );
  }
}
