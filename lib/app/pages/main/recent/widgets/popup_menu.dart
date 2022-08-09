import 'package:flutter/material.dart';

import '../../../../../domain/entities/call_record.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';

class RecentItemPopupMenu extends StatelessWidget {
  final CallRecord callRecord;
  final Function(RecentCallMenuAction action) onPopupMenuItemPress;

  const RecentItemPopupMenu({
    required this.callRecord,
    required this.onPopupMenuItemPress,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<RecentCallMenuAction>(
      onSelected: onPopupMenuItemPress,
      itemBuilder: (context) => [
        if (callRecord.isInbound) ...[
          PopupMenuItem<RecentCallMenuAction>(
            value: RecentCallMenuAction.none,
            enabled: false,
            child: _CallParty(
              title: context.msg.main.recent.list.item.popupMenu.from
                  .toUpperCase(),
              callParty: callRecord.caller,
            ),
          ),
          const PopupMenuDivider(),
        ],
        if (callRecord.answeredElsewhere && callRecord.isInbound) ...[
          PopupMenuItem<RecentCallMenuAction>(
            value: RecentCallMenuAction.none,
            enabled: false,
            child: _CallParty(
              title: context.msg.main.recent.list.item.popupMenu.answered
                  .toUpperCase(),
              callParty: callRecord.destination,
            ),
          ),
          const PopupMenuDivider(),
        ],
        PopupMenuItem<RecentCallMenuAction>(
          value: RecentCallMenuAction.copy,
          child: ListTile(
            leading: Container(
              width: 24,
              alignment: Alignment.center,
              child: const Icon(VialerSans.copy, size: 20),
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
              child: const Icon(VialerSans.phone, size: 20),
            ),
            title: Text(context.msg.main.recent.list.item.popupMenu.call),
          ),
        ),
      ],
      icon: Icon(
        VialerSans.ellipsis,
        color: context.brand.theme.colors.grey1,
        size: 16,
      ),
    );
  }
}

class _CallParty extends StatelessWidget {
  final String title;
  final CallParty callParty;

  static const _callFromFontSize = 14.0;

  const _CallParty({
    required this.title,
    required this.callParty,
  });

  String _text(BuildContext context) {
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
          _text(context),
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
