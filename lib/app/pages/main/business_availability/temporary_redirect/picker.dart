import 'package:flutter/material.dart';

import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect.dart';
import '../../../../resources/localizations.dart';
import '../../../../util/conditional_capitalization.dart';
import '../../../../widgets/stylized_button.dart';
import '../../../../widgets/stylized_dropdown.dart';
import 'explanation.dart';

class TemporaryRedirectPicker extends StatefulWidget {
  final TemporaryRedirect? activeRedirect;
  final Iterable<TemporaryRedirectDestination> availableDestinations;
  final Function(TemporaryRedirectDestination) onStart;
  final VoidCallback? onStop;

  const TemporaryRedirectPicker({
    super.key,
    required this.activeRedirect,
    required this.availableDestinations,
    required this.onStart,
    this.onStop,
  });

  @override
  State<TemporaryRedirectPicker> createState() =>
      _TemporaryRedirectPickerState();
}

class _TemporaryRedirectPickerState extends State<TemporaryRedirectPicker> {
  late TemporaryRedirectDestination _selectedDestination;

  @override
  void initState() {
    super.initState();
    _selectedDestination = widget.activeRedirect?.destination ??
        widget.availableDestinations.first;
  }

  void _changeSelectedDestination(TemporaryRedirectDestination? destination) {
    if (destination == null) return;

    setState(() {
      _selectedDestination = destination;
    });
  }

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
            context.msg.main.temporaryRedirect.dropdownTitle,
          ),
          const SizedBox(height: 8),
          StylizedDropdown<TemporaryRedirectDestination>(
            isExpanded: true,
            value: _selectedDestination,
            items: widget.availableDestinations.map(
              (dest) {
                return DropdownMenuItem<TemporaryRedirectDestination>(
                  value: dest,
                  child: Text(
                    dest.displayName,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ).toList(),
            onChanged: _changeSelectedDestination,
          ),
          const SizedBox(height: 16),
          StylizedButton.raised(
            colored: true,
            onPressed: () => widget.onStart(_selectedDestination),
            child: Text(
              context.msg.main.temporaryRedirect.actions.startRedirect.label
                  .toUpperCaseIfAndroid(context),
            ),
          ),
          if (widget.onStop != null) ...[
            const SizedBox(height: 12),
            StylizedButton.outline(
              colored: true,
              onPressed: widget.onStop,
              child: Text(
                context.msg.main.temporaryRedirect.actions.stopRedirect.label
                    .toUpperCaseIfAndroid(context),
              ),
            )
          ]
        ],
      ),
    );
  }
}
