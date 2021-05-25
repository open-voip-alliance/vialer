import 'package:flutter/material.dart';

import '../../../resources/theme.dart';
import '../../../util/brand.dart';
import '../../../widgets/animated_visibility.dart';

class ErrorAlert extends StatelessWidget {
  /// Whether the error box is visible.
  final bool visible;

  /// An inline error box is related to a specific input field,
  /// use a non-inline error box for general errors.
  final bool inline;
  final EdgeInsets padding;
  final String? title;
  final String message;

  const ErrorAlert({
    Key? key,
    required this.visible,
    required this.inline,
    this.padding = const EdgeInsets.all(4),
    required this.message,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedVisibility(
      visible: visible,
      child: Padding(
        padding: inline
            ? const EdgeInsets.all(0)
            : const EdgeInsets.only(bottom: 16),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 5),
            ClipPath(
              clipper: const ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(4),
                  ),
                ),
              ),
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: context.brand.theme.errorBackgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: context.brand.theme.errorContentColor,
                      width: 3.0,
                    ),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 9),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Icon(
                        VialerSans.exclamationMark,
                        size: 12,
                        color: context.brand.theme.errorContentColor,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: DefaultTextStyle.merge(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (title != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    title!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Text(message),
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
