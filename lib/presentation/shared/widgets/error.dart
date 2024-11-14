import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/theme.dart';

import 'animated_visibility.dart';

class ErrorAlert extends StatelessWidget {
  const ErrorAlert({
    required this.visible,
    required this.inline,
    required this.message,
    this.title,
    this.padding = const EdgeInsets.all(4),
    super.key,
  });

  /// Whether the error box is visible.
  final bool visible;

  /// An inline error box is related to a specific input field,
  /// use a non-inline error box for general errors.
  final bool inline;
  final EdgeInsets padding;
  final String? title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AnimatedVisibility(
      visible: visible,
      child: Padding(
        padding: inline ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 5),
            ClipPath(
              clipper: const ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  border: Border(
                    top: BorderSide(
                      color: context.brand.theme.colors.errorContent,
                      width: 3,
                    ),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 9),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.exclamation,
                          size: 12,
                          color: context.brand.theme.colors.errorContent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: DefaultTextStyle.merge(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6, bottom: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (title != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    title!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              Text(
                                message,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
