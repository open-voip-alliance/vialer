import 'package:dartx/dartx.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../domain/entities/call_record.dart';
import '../../../../../domain/entities/call_record_with_contact.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/contact.dart';
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
      leading: Avatar(
        name: callRecord.displayLabel,
        backgroundColor: calculateColorForPhoneNumber(
          context,
          callRecord.thirdPartyNumber,
        ),
        showFallback: callRecord.contact?.displayName == null,
        image: callRecord.contact?.avatar,
        fallback: const Text('#'),
      ),
      title: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onCallPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(callRecord.displayLabel),
            const SizedBox(height: 2),
            _RecentItemSubtitle(callRecord),
          ],
        ),
      ),
      // Empty onTap so we still keep the splash behavior
      onTap: () => {},
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
              title: Text(context.msg.main.recent.list.item.popupMenu.copy),
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
              title: Text(context.msg.main.recent.list.item.popupMenu.call),
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
    if (callRecord.wasMissed) {
      return context.msg.main.recent.list.item.wasMissed(_time);
    }

    final duration = prettyDuration(
      callRecord.duration,
      abbreviated: true,
      delimiter: ' ',
      spacer: '',
    );

    if (callRecord.isInbound) {
      return context.msg.main.recent.list.item.inbound(_time, duration);
    }

    if (callRecord.isOutbound) {
      return context.msg.main.recent.list.item.outbound(_time, duration);
    }

    if (callRecord.answeredElsewhere) {
      return context.msg.main.recent.list.item.answeredElsewhere(
        _answeredElsewhereText(),
        _time,
        duration,
      );
    }

    return '$_time - $duration';
  }

  String _answeredElsewhereText() {
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
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              _text(context),
              style: TextStyle(
                color: context.brand.theme.colors.grey4,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

extension CallDestinationLabel on CallRecordWithContact {
  String get displayLabel {
    final contact = this.contact;

    // We always want to prioritize a local contact in the user's phone.
    if (contact != null) return contact.displayName;

    // When a colleague is calling, they may have a display name setup so
    // we will use that. We don't want to use the display name for other calls
    // as dial-plans may set a variable callername, which would mean the
    // recents list doesn't show any relevant information about the caller.
    if (callType == CallType.colleague && thirdPartyName.isNotNullOrEmpty) {
      return thirdPartyName!;
    }

    return thirdPartyNumber;
  }
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
    final date = DateFormat.yMd().format(headerDate);
    final prefix = headerDate.isToday
        ? '${context.msg.main.recent.list.headers.today} - '
        : headerDate.wasYesterday
            ? '${context.msg.main.recent.list.headers.yesterday} - '
            : '';

    return '$prefix$date';
  }

  @override
  Widget build(BuildContext context) {
    final color = context.brand.theme.colors.grey4;

    final divider = Expanded(
      child: Divider(height: 1, color: color),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                divider,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _text(context, headerDate: date.toLocal()),
                    style: TextStyle(
                      color: color,
                    ),
                  ),
                ),
                divider,
              ],
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
