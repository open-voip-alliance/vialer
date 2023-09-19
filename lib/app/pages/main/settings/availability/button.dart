import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../resources/theme.dart';

class AvailabilityButton extends StatelessWidget {
  const AvailabilityButton({
    required this.text,
    this.leadingIcon,
    this.trailingIcon,
    this.onPressed,
    this.isActive = true,
    this.backgroundColor,
    this.foregroundColor,
    this.isDestinationOnline = true,
    super.key,
  });

  final VoidCallback? onPressed;
  final bool isActive;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final String text;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isDestinationOnline;

  Color _backgroundColor(BuildContext context) =>
      backgroundColor ?? context.brand.theme.colors.userAvailabilityAvailable;
  Color _foregroundColor(BuildContext context) =>
      foregroundColor ??
      context.brand.theme.colors.userAvailabilityAvailableAccent;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        backgroundColor: isActive
            ? _backgroundColor(context)
            : context.brand.theme.colors.userAvailabilityUnknown,
        foregroundColor: isActive
            ? _foregroundColor(context)
            : context.brand.theme.colors.userAvailabilityUnknownAccent,
        disabledBackgroundColor: isActive
            ? _backgroundColor(context)
            : context.brand.theme.colors.userAvailabilityUnknown,
        disabledForegroundColor: isActive
            ? _foregroundColor(context)
            : context.brand.theme.colors.userAvailabilityUnknownAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
                    child: AutoSizeText(
                      text.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      minFontSize: 8,
                      maxFontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingIcon != null)
              FaIcon(
                trailingIcon,
                size: 14,
                color: isDestinationOnline
                    ? null
                    : context.brand.theme.colors.red1,
              ),
          ],
        ),
      ),
    );
  }
}
