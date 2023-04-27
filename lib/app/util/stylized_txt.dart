import 'package:flutter/material.dart';
import 'package:styled_text/styled_text.dart' as styled_text;

/// Allows for styling text with a variety of inline-styles via the use of tags,
/// the benefit of which is that they can be supplied as a single string in the
/// translation files.
///
/// e.g. Set your destination above to <b>$voipAccount</b> to resume calls
/// to this device.
///
/// The list of default tags is shown below but additional custom tags can be
/// passed through. This should only be used in situations where the tag
/// only needs to be used once.
class StyledText extends StatelessWidget {
  const StyledText(this.text, {this.style, this.tags = const {}, super.key});

  final String text;
  final TextStyle? style;
  final Map<String, styled_text.StyledTextTag> tags;

  static final defaultTags = {
    'b': styled_text.StyledTextTag(
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    'i': styled_text.StyledTextTag(
      style: const TextStyle(fontStyle: FontStyle.italic),
    ),
    'u': styled_text.StyledTextTag(
      style: const TextStyle(decoration: TextDecoration.underline),
    ),
    's': styled_text.StyledTextTag(
      style: const TextStyle(decoration: TextDecoration.lineThrough),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return styled_text.StyledText(
      text: text,
      style: style,
      tags: {
        ...defaultTags,
        ...tags,
      },
    );
  }
}
