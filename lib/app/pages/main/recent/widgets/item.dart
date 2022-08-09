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
import 'popup_menu.dart';

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

  void _onPopupMenuItemPress(RecentCallMenuAction _action) {
    switch (_action) {
      case RecentCallMenuAction.copy:
        onCopyPressed();
        break;
      case RecentCallMenuAction.call:
        onCallPressed();
        break;
      case RecentCallMenuAction.none:
        return;
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
      trailing: RecentItemPopupMenu(
        callRecord: callRecord,
        onPopupMenuItemPress: _onPopupMenuItemPress,
      ),
    );
  }
}

class _RecentItemSubtitle extends StatelessWidget {
  final CallRecord callRecord;

  const _RecentItemSubtitle(this.callRecord, {Key? key}) : super(key: key);

  IconData _icon(BuildContext context) {
    if (callRecord.isIncomingAndAnsweredElsewhere) {
      return VialerSans.answeredElsewhere;
    }

    if (callRecord.wasMissed) return VialerSans.missedCall;

    return callRecord.isOutbound
        ? VialerSans.outgoingCall
        : VialerSans.incomingCall;
  }

  Color _iconColor(BuildContext context) {
    if (callRecord.wasMissed) return Colors.red;

    if (callRecord.isIncomingAndAnsweredElsewhere) {
      return context.brand.theme.colors.answeredElsewhere;
    }

    return context.brand.theme.colors.green1;
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
            Expanded(child: _RecentItemSubtitleText(callRecord)),
          ],
        ),
      ],
    );
  }
}

class _RecentItemSubtitleText extends StatelessWidget {
  final CallRecord callRecord;

  const _RecentItemSubtitleText(this.callRecord, {Key? key}) : super(key: key);

  String get _time => DateFormat.Hm().format(callRecord.date.toLocal());

  String get _duration => prettyDuration(
        callRecord.duration,
        abbreviated: true,
        delimiter: ' ',
        spacer: '',
      );

  String _callPartyText(CallParty party) {
    if (party.name == null ||
        party.name!.isEmpty ||
        party.name == party.number) {
      return '${party.number}';
    } else {
      return '${party.name}';
    }
  }

  String _text(BuildContext context) {
    if (callRecord.wasMissed) {
      return callRecord.isClientCall
          ? context.msg.main.recent.list.item.client.wasMissed(_time)
          : context.msg.main.recent.list.item.wasMissed(_time);
    }

    if (callRecord.isInbound) {
      return callRecord.isClientCall
          ? context.msg.main.recent.list.item.client.inbound(_time, _duration)
          : context.msg.main.recent.list.item.inbound(_time, _duration);
    }

    if (callRecord.isOutbound) {
      return callRecord.isClientCall
          ? context.msg.main.recent.list.item.client.outbound(
              _callPartyText(callRecord.caller),
              _time,
              _duration,
            )
          : context.msg.main.recent.list.item.outbound(_time, _duration);
    }

    return '$_time - $_duration';
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: context.brand.theme.colors.grey4,
      fontSize: 12,
    );

    if (callRecord.isIncomingAndAnsweredElsewhere) {
      return Row(
        children: [
          Flexible(
            child: Text(
              '${_callPartyText(callRecord.destination)} ',
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
          Text(
            context.msg.main.recent.list.item.answeredElsewhere(
              _time,
              _duration,
            ),
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          )
        ],
      );
    }

    return Text(
      _text(context),
      style: textStyle,
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
