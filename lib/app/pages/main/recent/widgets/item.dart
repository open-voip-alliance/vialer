import 'package:dartx/dartx.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../domain/entities/call_record.dart';
import '../../../../../domain/entities/call_record_with_contact.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/contact.dart';
import '../../contacts/widgets/group_header.dart';
import '../../util/color.dart';
import '../../widgets/avatar.dart';

enum _Action {
  copy,
  call,
}

class RecentCallItem extends StatelessWidget {
  final CallRecordWithContact callRecord;

  /// Also called when whole item is pressed.
  final VoidCallback onCallPressed;
  final VoidCallback onCopyPressed;

  const RecentCallItem({
    Key? key,
    required this.callRecord,
    required this.onCopyPressed,
    required this.onCallPressed,
  }) : super(key: key);

  void _onPopupMenuItemPress(_Action _action) {
    switch (_action) {
      case _Action.copy:
        onCopyPressed();
        break;
      case _Action.call:
        onCallPressed();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: onCallPressed,
      leading: Avatar(
        name: callRecord.displayLabel,
        backgroundColor: calculateColorForPhoneNumber(
          context,
          callRecord.thirdPartyNumber,
        ),
        showFallback: callRecord.contact?.displayName == null,
        fallback: const Icon(VialerSans.phone, size: 20),
      ),
      title: Text(callRecord.displayLabel),
      subtitle: _RecentItemSubtitle(callRecord),
      trailing: PopupMenuButton(
        onSelected: _onPopupMenuItemPress,
        itemBuilder: (context) => [
          PopupMenuItem<_Action>(
            value: _Action.copy,
            child: ListTile(
              leading: Container(
                width: 24,
                alignment: Alignment.center,
                child: const Icon(VialerSans.copy, size: 20),
              ),
              title: Text(context.msg.main.recent.list.popupMenu.copy),
            ),
          ),
          PopupMenuItem<_Action>(
            value: _Action.call,
            child: ListTile(
              leading: Container(
                width: 24,
                alignment: Alignment.center,
                child: const Icon(VialerSans.phone, size: 20),
              ),
              title: Text(context.msg.main.recent.list.popupMenu.call),
            ),
          ),
        ],
        icon: Icon(
          VialerSans.ellipsis,
          color: context.brand.theme.colors.grey1,
          size: 16,
        ),
      ),
    );
  }
}

class _RecentItemSubtitle extends StatelessWidget {
  final CallRecord callRecord;

  const _RecentItemSubtitle(this.callRecord, {Key? key}) : super(key: key);

  String get _time => DateFormat.Hm().format(callRecord.date.toLocal());

  IconData _icon(BuildContext context) {
    if (callRecord.answeredElsewhere) return VialerSans.answeredElsewhere;

    if (callRecord.wasMissed) return VialerSans.missedCall;

    return callRecord.isOutbound
        ? VialerSans.outgoingCall
        : VialerSans.incomingCall;
  }

  Color _iconColor(BuildContext context) {
    if (callRecord.wasMissed) return Colors.red;

    if (callRecord.answeredElsewhere) {
      return context.brand.theme.colors.answeredElsewhere;
    }

    return context.brand.theme.colors.green1;
  }

  String _text(BuildContext context) {
    if (callRecord.wasMissed) return _time;

    final duration = prettyDuration(
      callRecord.duration,
      abbreviated: true,
      delimiter: ' ',
      spacer: '',
    );

    return '$_time, $duration';
  }

  String _createAnsweredElsewhereText() {
    if (callRecord.destination.name == null ||
        callRecord.destination.name!.isEmpty ||
        callRecord.destination.name == callRecord.destination.number) {
      return '${callRecord.destination.number}';
    } else {
      return '${callRecord.destination.name} '
          '(${callRecord.destination.number})';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: <Widget>[
            Icon(
              _icon(context),
              color: _iconColor(context),
              size: 12,
            ),
            const SizedBox(width: 8),
            Text(
              _text(context),
              style: TextStyle(color: context.brand.theme.colors.grey4),
            ),
          ],
        ),
        if (callRecord.answeredElsewhere)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _createAnsweredElsewhereText(),
              style: TextStyle(color: context.brand.theme.colors.grey4),
            ),
          ),
      ],
    );
  }
}

extension CallDestinationLabel on CallRecordWithContact {
  String get displayLabel =>
      contact?.displayName ?? thirdPartyName ?? thirdPartyNumber;
}

class RecentCallHeader extends StatelessWidget {
  final DateTime date;
  final bool isFirst;
  final Widget child;

  const RecentCallHeader({
    required this.date,
    required this.child,
    this.isFirst = false,
  });

  String _text(
    BuildContext context, {
    required DateTime headerDate,
  }) {
    final today = DateTime.now().toLocal();
    final yesterday = today.subtract(
      const Duration(
        days: 1,
      ),
    );

    if (headerDate.isAtSameDayAs(today)) {
      return context.msg.main.recent.list.headers.today.toUpperCase();
    } else if (headerDate.isAtSameDayAs(yesterday)) {
      return context.msg.main.recent.list.headers.yesterday.toUpperCase();
    }

    return DateFormat('d MMMM y').format(headerDate);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isFirst) const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
            top: isFirst ? 15 : 10,
          ),
          child: GroupHeader(
            group: _text(
              context,
              headerDate: date.toLocal(),
            ),
            padding: const EdgeInsets.all(0),
          ),
        ),
        child,
      ],
    );
  }
}
