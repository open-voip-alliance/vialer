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
  final CallRecordWithContact call;

  /// Also called when whole item is pressed.
  final VoidCallback onCallPressed;
  final VoidCallback onCopyPressed;

  const RecentCallItem({
    Key? key,
    required this.call,
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
        name: call.displayName,
        backgroundColor: calculateColorForPhoneNumber(
          context,
          call.destinationNumber,
        ),
        showFallback: call.contact?.name == null,
        fallback: const Icon(VialerSans.phone, size: 20),
      ),
      title: Text(
        call.direction == Direction.inbound
            ? call.callerNumber
            : call.displayName,
      ),
      subtitle: _RecentItemSubtitle(call),
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          callRecord.wasMissed
              ? VialerSans.missedCall
              : callRecord.isOutbound
                  ? VialerSans.outgoingCall
                  : VialerSans.incomingCall,
          color: callRecord.wasMissed ? Colors.red : context.brand.theme.green1,
          size: 12,
        ),
        const SizedBox(width: 8),
        Text(
          '${_timeAgo(context)}',
          style: TextStyle(color: context.brand.theme.grey4),
        ),
      ],
    );
  }
}

extension CallDestinationName on CallRecordWithContact {
  String get displayName =>
      contact?.name ?? destinationName ?? destinationNumber;
}
