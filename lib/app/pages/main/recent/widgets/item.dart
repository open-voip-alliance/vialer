import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../resources/theme.dart';
import '../../../../../domain/entities/call.dart';

import '../../../../resources/localizations.dart';

import '../../util/color.dart';

enum _Action {
  copy,
  call,
}

class RecentCallItem extends StatelessWidget {
  final Call call;

  /// Also called when whole item is pressed.
  final VoidCallback onCallPressed;
  final VoidCallback onCopyPressed;

  const RecentCallItem({
    Key key,
    this.call,
    this.onCopyPressed,
    this.onCallPressed,
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
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      onTap: onCallPressed,
      leading: _RecentItemAvatar(call),
      title: Text(call.destinationName),
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
                child: Icon(VialerSans.copy, size: 20),
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
                child: Icon(VialerSans.phone, size: 20),
              ),
              title: Text(context.msg.main.recent.list.popupMenu.call),
            ),
          ),
        ],
        icon: Icon(
          VialerSans.ellipsis,
          color: context.brandTheme.grey1,
          size: 16,
        ),
      ),
    );
  }
}

class _RecentItemAvatar extends StatelessWidget {
  final Call call;

  const _RecentItemAvatar(this.call, {Key key}) : super(key: key);

  String get _letters {
    final letters = call.destinationName.split(' ').map(
          (word) => word.substring(0, 1).toUpperCase(),
        );

    if (letters.length == 1) {
      return letters.first;
    } else {
      return letters.first + letters.last;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      alignment: Alignment.center,
      child: CircleAvatar(
        foregroundColor: Colors.white,
        backgroundColor:
            calculateColorForPhoneNumber(context, call.destinationNumber),
        child: call.destinationContactName != null
            ? Text(
                _letters,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            : Icon(VialerSans.phone, size: 20),
      ),
    );
  }
}

class _RecentItemSubtitle extends StatelessWidget {
  final Call call;

  const _RecentItemSubtitle(this.call, {Key key}) : super(key: key);

  String get _time => DateFormat.Hm().format(call.localDate);

  String get _date => DateFormat('dd-MM-yy').format(call.localDate);

  String _timeAgo(BuildContext context) {
    final elapsed = DateTime.now().millisecondsSinceEpoch -
        call.localDate.millisecondsSinceEpoch;
    final minutes = (elapsed / (1000 * 60));
    final hours = (elapsed / (1000 * 60 * 60));

    if (hours < 1) {
      if (minutes.round() == 1) {
        return (context.msg.main.recent.list.minuteAgo());
      } else {
        return (context.msg.main.recent.list.minutesAgo(minutes.round()));
      }
    } else if (hours < 24) {
      if (hours.round() == 1) {
        return ('${context.msg.main.recent.list.hourAgo()}, $_time');
      } else {
        return ('${context.msg.main.recent.list.hoursAgo(hours.round())},'
            '$_time');
      }
    } else {
      return ('$_date, $_time');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          call.wasMissed
              ? VialerSans.missedCall
              : call.direction == Direction.outbound
                  ? VialerSans.outgoingCall
                  : VialerSans.incomingCall,
          color: call.wasMissed ? Colors.red : context.brandTheme.green1,
          size: 12,
        ),
        SizedBox(width: 8),
        Text(
          '${_timeAgo(context)}',
          style: TextStyle(color: context.brandTheme.grey4),
        ),
      ],
    );
  }
}

extension CallDestinationName on Call {
  String get destinationName => destinationContactName ?? destinationNumber;
}
