import 'package:flutter/material.dart';
import '../../../../../resources/localizations.dart';

class DoNotShowAgainCheckbox extends StatelessWidget {
  const DoNotShowAgainCheckbox({
    required this.checked,
    required this.onChanged,
  });

  final bool checked;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = context.msg.main.outgoingCLI.prompt;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: CheckboxListTile(
        title: Text(
          strings.checkbox.label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        subtitle: Text(
          strings.checkbox.helpText,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        value: checked,
        onChanged: (value) => value != null ? onChanged(value) : null,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
