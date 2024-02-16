import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../data/models/call_records/call_record.dart';
import 'item.dart';

class RecentItemPopupMenu extends StatelessWidget {
  const RecentItemPopupMenu({
    required this.callRecord,
    required this.onPopupMenuItemPress,
    super.key,
  });

  final CallRecord callRecord;
  final void Function(RecentCallMenuAction action) onPopupMenuItemPress;

  List<PopupMenuEntry<RecentCallMenuAction>> _createInformationItem({
    required String title,
    required List<CallParty> callParties,
  }) {
    return [
      PopupMenuItem<RecentCallMenuAction>(
        value: RecentCallMenuAction.none,
        enabled: false,
        child: _CallParties(
          title: title.toUpperCase(),
          callParties: callParties,
        ),
      ),
      const PopupMenuDivider(),
    ];
  }

  /// Creates all the items that will change based on the type of call record
  /// that we are currently rendering.
  List<PopupMenuEntry<RecentCallMenuAction>> _createRecordSpecificItems(
    BuildContext context,
  ) {
    if (callRecord.renderType == CallRecordRenderType.other) {
      return [
        if (callRecord.isInbound)
          ..._createInformationItem(
            title: context.msg.main.recent.list.item.popupMenu.from,
            callParties: [callRecord.caller],
          ),
        if (callRecord.answeredElsewhere && callRecord.isInbound)
          ..._createInformationItem(
            title: context.msg.main.recent.list.item.popupMenu.answered,
            callParties: [callRecord.destination],
          ),
      ];
    }

    if (callRecord.renderType == CallRecordRenderType.internalCall) {
      return _createInformationItem(
        title: context.msg.main.recent.list.item.popupMenu.internal.title
            .toUpperCase(),
        callParties: [callRecord.caller, callRecord.destination],
      );
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final recordSpecificItems = _createRecordSpecificItems(context);

    return PopupMenuButton<RecentCallMenuAction>(
      onSelected: onPopupMenuItemPress,
      itemBuilder: (context) => [
        ...recordSpecificItems,
        PopupMenuItem<RecentCallMenuAction>(
          value: RecentCallMenuAction.copy,
          child: ListTile(
            leading: Container(
              width: 24,
              alignment: Alignment.center,
              child: const FaIcon(FontAwesomeIcons.copy, size: 20),
            ),
            title: Text(context.msg.main.recent.list.item.popupMenu.copy),
          ),
        ),
        PopupMenuItem<RecentCallMenuAction>(
          value: RecentCallMenuAction.call,
          child: ListTile(
            leading: Container(
              width: 24,
              alignment: Alignment.center,
              child: const FaIcon(FontAwesomeIcons.phone, size: 20),
            ),
            title: Text(context.msg.main.recent.list.item.popupMenu.call),
          ),
        ),
      ],
      icon: FaIcon(
        FontAwesomeIcons.ellipsisVertical,
        color: context.brand.theme.colors.grey1,
        size: 16,
      ),
    );
  }
}

class _CallParties extends StatelessWidget {
  const _CallParties({
    required this.title,
    required this.callParties,
  });

  final String title;
  final List<CallParty> callParties;

  static const _callFromFontSize = 14.0;

  String _text(CallParty callParty, BuildContext context) {
    if (!callParty.hasName) {
      return callParty.number;
    }

    return '${callParty.name!} (${callParty.number})';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: _callFromFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          callParties.map((party) => _text(party, context)).join(' & '),
          style: const TextStyle(
            fontSize: _callFromFontSize,
          ),
        ),
      ],
    );
  }
}

enum RecentCallMenuAction {
  copy,
  call,
  none,
}
