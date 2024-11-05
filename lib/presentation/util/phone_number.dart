import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:vialer/domain/util/phone_number.dart';
import 'package:vialer/presentation/resources/localizations.dart';

import '../../../data/models/calling/outgoing_number/outgoing_number.dart';

class FormattedPhoneNumber extends StatelessWidget {
  const FormattedPhoneNumber(
    this.number, {
    this.style,
    required this.formattedNumber,
    super.key,
  });

  factory FormattedPhoneNumber.outgoingNumber(
    BuildContext context,
    OutgoingNumber outgoingNumber, {
    required TextStyle? style,
  }) {
    final n = outgoingNumber.valueOrEmpty;

    if (outgoingNumber.isSuppressed) {
      return FormattedPhoneNumber(
        outgoingNumber.valueOrEmpty,
        // We know the exact format of outgoing number.
        formattedNumber: context.msg.main.outgoingCLI.prompt.suppress.number,
        style: style,
      );
    }

    return FormattedPhoneNumber(
      outgoingNumber.valueOrEmpty,
      // We know the exact format of outgoing number.
      formattedNumber: '(+${n[1]}${n[2]}) ${n[3]}${n[4]} ${n.slice(5)}',
      style: style,
    );
  }

  final String number;
  final String formattedNumber;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return PhoneNumberText(
      child: Text(
        formattedNumber,
        style: style,
        textAlign: TextAlign.start,
      ),
      content: number.isNotEmpty ? number : formattedNumber,
    );
  }
}

/// Will automatically attempt to parse the content of any text received and
/// create a semantics label where anything that looks like a phone number
/// is read properly.
///
/// As we support a very broad range of phone numbers this pretty much means
/// any number will be matched so this must only be used in situations where
/// you would never want to include a regular number.
class PhoneNumberText extends StatelessWidget {
  const PhoneNumberText({
    required this.child,
    this.content,
    this.semanticsLabel,
    super.key,
  });

  final Widget child;

  /// Allows for a hard-coded semantics label as you, conditionally, may want
  /// to be explicit about it. If this isn't conditional then don't use
  /// [PhoneNumberText].
  final String? semanticsLabel;

  /// If you aren't providing a [Text] widget as [child] then you must set this
  /// text property.
  final String? content;

  @override
  Widget build(BuildContext context) {
    assert(child is Text || content != null);

    return Semantics(
      label: _semanticsLabel,
      child: ExcludeSemantics(child: child),
    );
  }

  String? get _semanticsLabel {
    final widget = child;

    final text = widget is Text ? widget.data : content!;

    if (text == null || text.isEmpty) return text;

    return text
        .split(' ')
        .map(
          (word) => word.looksLikePhoneNumber()
              ? word.phoneNumberSemanticLabel
              : word,
        )
        .join(' ');
  }
}

/// These characters will not be included when reading a phone number.
const _ignoredCharacters = [')', '('];

extension PhoneNumberSemantics on String {
  String get phoneNumberSemanticLabel => split('')
      .filter((element) => !_ignoredCharacters.contains(element))
      .join(' ');

  String get asSemanticsLabelIfPhoneNumber =>
      looksLikePhoneNumber() ? phoneNumberSemanticLabel : this;
}
