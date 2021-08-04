import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../domain/entities/call_record.dart';
import '../../../../../domain/entities/call_record_with_contact.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/brand.dart';
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
          callRecord.destinationNumber,
        ),
        showFallback: callRecord.contact?.name == null,
        fallback: const Icon(VialerSans.phone, size: 20),
      ),
      title: Text(
        callRecord.direction == Direction.inbound
            ? callRecord.callerNumber
            : callRecord.displayLabel,
      ),
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
          color: context.brand.theme.grey1,
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

  String get _date => DateFormat('dd-MM-yy').format(callRecord.date.toLocal());

  String _timeAgo(BuildContext context) {
    final duration = DateTime.now().difference(callRecord.date.toLocal());

    if (duration.inHours < 1) {
      if (duration.inMinutes == 1) {
        return context.msg.main.recent.list.minuteAgo;
      } else {
        return context.msg.main.recent.list.minutesAgo(duration.inMinutes);
      }
    } else if (duration.inHours < Duration.hoursPerDay) {
      if (duration.inHours == 1) {
        return '${context.msg.main.recent.list.hourAgo}, $_time';
      } else {
        return '${context.msg.main.recent.list.hoursAgo(duration.inHours)}, '
            '$_time';
      }
    } else {
      return '$_date, $_time';
    }
  }

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
      return context.brand.theme.answeredElsewhere;
    }

    return context.brand.theme.green1;
  }

  String _text(BuildContext context) => '${_timeAgo(context)}';

  String _createAnsweredElsewhereText() {
    if (callRecord.destinationName == null ||
        callRecord.destinationName!.isEmpty ||
        callRecord.destinationName == callRecord.destinationNumber) {
      return '${callRecord.destinationNumber}';
    } else {
      return '${callRecord.destinationName} (${callRecord.destinationNumber})';
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
              style: TextStyle(color: context.brand.theme.grey4),
            ),
          ],
        ),
        if (callRecord.answeredElsewhere)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _createAnsweredElsewhereText(),
              style: TextStyle(color: context.brand.theme.grey4),
            ),
          ),
      ],
    );
  }
}

extension CallDestinationLabel on CallRecordWithContact {
  String get displayLabel =>
      contact?.name ?? destinationName ?? destinationNumber;
}
