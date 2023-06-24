import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:vialer/domain/user/settings/call_setting.dart';

import '../../../resources/localizations.dart';

class PhoneNumber extends StatelessWidget {
  const PhoneNumber(
    this.number, {
    this.style,
    this.semanticsLabel,
    required this.formattedNumber,
    super.key,
  });

  factory PhoneNumber.outgoingNumber(
    BuildContext context,
    OutgoingNumber outgoingNumber, {
    required TextStyle? style,
  }) {
    final n = outgoingNumber.valueOrEmpty;

    if (outgoingNumber.isSuppressed) {
      return PhoneNumber(
        outgoingNumber.valueOrEmpty,
        // We know the exact format of outgoing number.
        formattedNumber: context.msg.main.outgoingCLI.prompt.suppress.number,
        semanticsLabel: context.msg.main.outgoingCLI.prompt.suppress.number,
        style: style,
      );
    }

    return PhoneNumber(
      outgoingNumber.valueOrEmpty,
      // We know the exact format of outgoing number.
      formattedNumber: '(+${n[1]}${n[2]}) ${n[3]}${n[4]} ${n.slice(4)}',
      style: style,
    );
  }

  final String number;
  final String formattedNumber;

  /// Provide a custom semantics label to the phone number, when provided
  /// [number] will be ignored.
  final String? semanticsLabel;
  final TextStyle? style;

  String get _semanticsLabel => semanticsLabel ?? number.split('').join(' ');

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _semanticsLabel,
      child: ExcludeSemantics(
        child: Text(
          formattedNumber,
          style: style,
          textAlign: TextAlign.start,
        ),
      ),
    );
  }
}
