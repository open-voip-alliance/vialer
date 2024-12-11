import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vialer/data/models/user/refresh/user_refresh_task.dart';
import 'package:vialer/domain/usecases/user/refresh/refresh_user.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../data/models/business_availability/temporary_redirect/temporary_redirect.dart';
import '../../../../../../data/models/voipgrid/web_page.dart';
import '../../../../shared/pages/web_view.dart';
import '../../../../shared/widgets/stylized_dropdown.dart';
import '../../../settings/widgets/settings_button.dart';
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

  void _openPortal() =>
      WebViewPage.open(context, to: WebPage.addVoicemail).then(
        (value) => RefreshUser()(
          tasksToPerform: [UserRefreshTask.clientVoicemailAccounts],
        ),
      );

  String get _mainActionText => widget.activeRedirect != null
      ? context.msg.main.temporaryRedirect.actions.changeRedirect.label
      : context.msg.main.temporaryRedirect.actions.startRedirect.label;

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
            hasDestinations: _hasAvailableDestinations,
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
                    ),
                  ],
            onChanged:
                _hasAvailableDestinations ? _changeSelectedDestination : null,
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
                  TextSpan(text: ' '),
                  TextSpan(
                    text: context.msg.main.temporaryRedirect.dropdown
                        .noVoicemails.hint.link,
                    style:
                        const TextStyle(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = _openPortal,
                  ),
                  TextSpan(text: ' '),
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
              initialDate: widget.activeRedirect?.endsAt,
            ),
          ),
          const SizedBox(height: 16),
          SettingsButton(
            text: _mainActionText,
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
          ),
          if (widget.onCancel != null) ...[
            const SizedBox(height: 12),
            SettingsButton(
              onPressed: widget.onCancel,
              text: context.msg.generic.button.cancel,
              solid: false,
            ),
          ],
          if (widget.onStop != null) ...[
            const Spacer(),
            const SizedBox(height: 48),
            SettingsButton(
              onPressed: _actionable
                  ? () => unawaited(_handleAction(widget.onStop!))
                  : null,
              text: context
                  .msg.main.temporaryRedirect.actions.stopRedirect.labelOngoing,
              solid: false,
            ),
          ],
        ],
      ),
    );
  }
}
