import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vialer/app/pages/main/call/outgoing_number_prompt/outgoing_number_selection.dart';
import 'package:vialer/app/pages/main/call/outgoing_number_prompt/widgets/basic_list.dart';
import 'package:vialer/app/pages/main/call/outgoing_number_prompt/widgets/checkbox.dart';
import 'package:vialer/app/pages/main/call/outgoing_number_prompt/widgets/expanded_list.dart';
import 'package:vialer/app/pages/main/call/outgoing_number_prompt/widgets/heading.dart';
import 'package:vialer/app/pages/main/call/outgoing_number_prompt/widgets/information.dart';
import 'package:vialer/app/pages/main/call/outgoing_number_prompt/widgets/item.dart';
import 'package:vialer/app/pages/main/widgets/caller.dart';
import 'package:vialer/app/resources/messages.i18n.dart';
import 'package:vialer/app/util/context_extensions.dart';

import '../../../../../domain/user/settings/call_setting.dart';

import '../../../../resources/localizations.dart';

typedef OutgoingNumberSelectedCallback = void Function(OutgoingNumber);

class OutgoingNumberPrompt extends ConsumerWidget {
  const OutgoingNumberPrompt({
    required this.onOutgoingNumberConfigured,
    super.key,
  });

  final OutgoingNumberSelectedCallback onOutgoingNumberConfigured;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(outgoingNumberSelectionProvider);

    final textStyle = TextStyle(color: context.colors.userAvailabilityOffline);

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: TextTheme(
          titleLarge: textStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: textStyle.copyWith(fontSize: 16),
          titleSmall: textStyle,
          bodySmall: textStyle.copyWith(color: context.colors.grey6),
          bodyMedium: textStyle.copyWith(fontSize: 16),
          labelMedium: textStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      child: switch (state) {
        Failed() => _Failed(),
        Updating() => _Updating(),
        Ready() => _Ready(onOutgoingNumberConfigured),
      },
    );
  }
}

class _Ready extends ConsumerWidget {
  const _Ready(this.onOutgoingNumberConfigured);

  final OutgoingNumberSelectedCallback onOutgoingNumberConfigured;

  /// The maximum number of outgoing numbers to show before the list is
  /// converted to the expanded list style.
  static const _maxOutgoingNumbersBeforeExpandedList = 4;

  void configureOutgoingNumber(
    OutgoingNumber outgoingNumber,
    WidgetRef ref,
  ) async {
    await ref
        .read(outgoingNumberSelectionProvider.notifier)
        .changeOutgoingNumber(number: outgoingNumber);

    onOutgoingNumberConfigured(outgoingNumber);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(outgoingNumberSelectionProvider);

    final callback = (OutgoingNumber outgoingNumber) => configureOutgoingNumber(
          outgoingNumber,
          ref,
        );

    return _Layout(
      header: Heading(),
      children: [
        Column(
          children: [
            Subheading(context.strings.currentOutgoingNumber.label),
            OutgoingNumberItem(
              item: state.currentOutgoingNumber,
              onOutgoingNumberSelected: callback,
              active: true,
            ),
            state.outgoingNumbers.length < _maxOutgoingNumbersBeforeExpandedList
                ? BasicList(state, onOutgoingNumberSelected: callback)
                : ExpandedList(state, onOutgoingNumberSelected: callback),
            if (!state.currentOutgoingNumber.isSuppressed) ...[
              Subheading(context.strings.suppress.title),
              OutgoingNumberItem(
                item: OutgoingNumber.suppressed(),
                onOutgoingNumberSelected: callback,
                active: false,
              ),
            ],
            DoNotShowAgainCheckbox(
              checked: state.doNotShowAgain,
              onChanged: (value) => ref
                  .read(outgoingNumberSelectionProvider.notifier)
                  .doNotShowAgain(value),
            ),
          ],
        ),
      ],
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed();

  @override
  Widget build(BuildContext context) {
    return Information(
      icon: FaIcon(
        FontAwesomeIcons.circleExclamation,
        color: context.colors.red1,
      ),
      title: context.strings.updatingNumber.error.title,
      subtitle: context.strings.updatingNumber.error.description,
    );
  }
}

class _Updating extends StatelessWidget {
  const _Updating();

  @override
  Widget build(BuildContext context) {
    return Information(
      icon: Container(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(color: context.colors.primary),
      ),
      title: context.strings.updatingNumber.title,
      subtitle: context.strings.updatingNumber.description,
    );
  }
}

class _Layout extends StatelessWidget {
  const _Layout({required this.header, required this.children});

  final Widget header;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallerCubit, CallerState>(
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: children,
              ),
            ),
          ],
        );
      },
    );
  }
}

extension OutgoingNumberList on Iterable<OutgoingNumber> {
  List<Widget> toWidgets(
    OutgoingNumberSelectedCallback callback,
    OutgoingNumber current,
  ) =>
      map((item) => OutgoingNumberItem(
            item: item,
            onOutgoingNumberSelected: callback,
            active: current == this,
          )).toList(growable: false);
}

extension on BuildContext {
  PromptOutgoingCLIMainMessages get strings => msg.main.outgoingCLI.prompt;
}
