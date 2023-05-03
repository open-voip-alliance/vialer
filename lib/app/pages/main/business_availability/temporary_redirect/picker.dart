import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect.dart';
import '../../../../../domain/voipgrid/web_page.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme/brand_theme.dart';
import '../../../../util/brand.dart';
import '../../../../util/conditional_capitalization.dart';
import '../../../../widgets/stylized_button.dart';
import '../../../../widgets/stylized_dropdown.dart';
import '../../../web_view/page.dart';
import 'date_field.dart';
import 'explanation.dart';
import 'field.dart';

class TemporaryRedirectPicker extends StatefulWidget {
  const TemporaryRedirectPicker({
    required this.activeRedirect,
    required this.availableDestinations,
    required this.onStart,
    this.onStop,
    this.onCancel,
    super.key,
  });

  final TemporaryRedirect? activeRedirect;
  final Iterable<TemporaryRedirectDestination> availableDestinations;
  final Future<void> Function(TemporaryRedirectDestination, DateTime) onStart;
  final Future<void> Function()? onStop;
  final VoidCallback? onCancel;

  @override
  State<TemporaryRedirectPicker> createState() =>
      _TemporaryRedirectPickerState();
}

class _TemporaryRedirectPickerState extends State<TemporaryRedirectPicker> {
  TemporaryRedirectDestination? _selectedDestination;

  bool get _hasAvailableDestinations => widget.availableDestinations.isNotEmpty;

  late final _untilDateNotifier = ValueNotifier<DateTime?>(null);

  bool _hasCorrectUntilDate = true;
  bool _actionable = true;

  @override
  void initState() {
    super.initState();
    _selectedDestination = widget.activeRedirect?.destination ??
        widget.availableDestinations.firstOrNull;

    _untilDateNotifier.addListener(_onUntilDateChange);
  }

  void _onUntilDateChange() {
    // Side effect: Explanation will be updated with correct date.
    setState(() {
      _hasCorrectUntilDate = _untilDateNotifier.value != null;
    });
  }

  Future<void> _handleAction(Future<void> Function() action) async {
    // ignore: avoid_positional_boolean_parameters
    void actionable(bool value) => setState(() {
          _actionable = value;
        });

    actionable(false);

    try {
      await action();
    } finally {
      actionable(true);
    }
  }

  void _changeSelectedDestination(TemporaryRedirectDestination? destination) {
    if (destination == null) return;

    setState(() {
      _selectedDestination = destination;
    });
  }

  void _openPortal() => unawaited(
        WebViewPage.open(context, to: WebPage.addVoicemail),
      );

  String get _mainActionText {
    final text = widget.activeRedirect != null
        ? context.msg.main.temporaryRedirect.actions.changeRedirect.label
        : context.msg.main.temporaryRedirect.actions.startRedirect.label;

    return text.toUpperCaseIfAndroid(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TemporaryRedirectExplanation(
            currentDestination: _selectedDestination,
            endsAt: _untilDateNotifier.value,
          ),
          const SizedBox(height: 16),
          FieldHeader(
            context.msg.main.temporaryRedirect.dropdown.title,
          ),
          const SizedBox(height: 8),
          StylizedDropdown<TemporaryRedirectDestination>(
            isExpanded: true,
            value: _selectedDestination,
            items: _hasAvailableDestinations
                ? widget.availableDestinations.map(
                    (dest) {
                      return DropdownMenuItem<TemporaryRedirectDestination>(
                        value: dest,
                        child: Text(
                          dest.displayName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ).toList()
                : [
                    DropdownMenuItem<TemporaryRedirectDestination>(
                      child: Text(
                        context.msg.main.temporaryRedirect.dropdown.noVoicemails
                            .item,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  ],
            onChanged: _changeSelectedDestination,
          ),
          if (!_hasAvailableDestinations) ...[
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: context.msg.main.temporaryRedirect.dropdown
                        .noVoicemails.hint.start,
                  ),
                  TextSpan(
                    text: context.msg.main.temporaryRedirect.dropdown
                        .noVoicemails.hint.link,
                    style:
                        const TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = _openPortal,
                  ),
                  TextSpan(
                    text: context.msg.main.temporaryRedirect.dropdown
                        .noVoicemails.hint.end,
                  ),
                ],
              ),
              style: TextStyle(
                color: context.brand.theme.colors.red1,
              ),
            ),
          ],
          const SizedBox(height: 16),
          FieldHeader(context.msg.main.temporaryRedirect.until.title),
          const SizedBox(height: 8),
          Flexible(
            child: DateField(
              notifier: _untilDateNotifier,
            ),
          ),
          const SizedBox(height: 16),
          StylizedButton.raised(
            colored: true,
            onPressed: _actionable &&
                    _hasCorrectUntilDate &&
                    _selectedDestination != null
                ? () async => _handleAction(
                      () => widget.onStart(
                        _selectedDestination!,
                        _untilDateNotifier.value!,
                      ),
                    )
                : null,
            child: Text(_mainActionText),
          ),
          if (widget.onCancel != null) ...[
            const SizedBox(height: 12),
            StylizedButton.outline(
              colored: true,
              onPressed: widget.onCancel,
              child: Text(
                context.msg.generic.button.cancel.toUpperCaseIfAndroid(context),
              ),
            ),
          ],
          if (widget.onStop != null) ...[
            const Spacer(),
            const SizedBox(height: 48),
            StylizedButton.outline(
              colored: true,
              onPressed: _actionable
                  ? () => unawaited(_handleAction(widget.onStop!))
                  : null,
              child: Text(
                context.msg.main.temporaryRedirect.actions.stopRedirect
                    .labelOngoing
                    .toUpperCaseIfAndroid(context),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
