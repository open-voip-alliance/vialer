import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme/brand_theme.dart';
import '../../../../util/brand.dart';
import '../../../../util/conditional_capitalization.dart';
import '../../../../widgets/stylized_button.dart';
import '../../../../widgets/stylized_dropdown.dart';
import 'explanation.dart';

class TemporaryRedirectPicker extends StatefulWidget {
  final TemporaryRedirect? activeRedirect;
  final Iterable<TemporaryRedirectDestination> availableDestinations;
  final Function(TemporaryRedirectDestination) onStart;
  final VoidCallback? onStop;
  final VoidCallback? onCancel;

  const TemporaryRedirectPicker({
    super.key,
    required this.activeRedirect,
    required this.availableDestinations,
    required this.onStart,
    this.onStop,
    this.onCancel,
  });

  @override
  State<TemporaryRedirectPicker> createState() =>
      _TemporaryRedirectPickerState();
}

class _TemporaryRedirectPickerState extends State<TemporaryRedirectPicker> {
  TemporaryRedirectDestination? _selectedDestination;

  bool get _hasAvailableDestinations => widget.availableDestinations.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _selectedDestination = widget.activeRedirect?.destination ??
        widget.availableDestinations.firstOrNull;
  }

  void _changeSelectedDestination(TemporaryRedirectDestination? destination) {
    if (destination == null) return;

    setState(() {
      _selectedDestination = destination;
    });
  }

  // TODO?: Can be in-app webview
  void _openPortal() => launchUrl(context.brand.url);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TemporaryRedirectExplanation(
            currentDestination: _selectedDestination,
          ),
          const SizedBox(height: 16),
          Text(
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
                      value: null,
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
          StylizedButton.raised(
            colored: true,
            onPressed: _selectedDestination != null
                ? () => widget.onStart(_selectedDestination!)
                : null,
            child: Text(
              (widget.activeRedirect != null
                      ? context.msg.main.temporaryRedirect.actions
                          .changeRedirect.label
                      : context.msg.main.temporaryRedirect.actions.startRedirect
                          .label)
                  .toUpperCaseIfAndroid(context),
            ),
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
              onPressed: widget.onStop,
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
