import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../../domain/entities/call_record.dart';
import '../../../../../domain/entities/call_record_with_contact.dart';
import '../../../../../domain/entities/client_call_record.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/contact.dart';
import '../../util/color.dart';
import '../../widgets/avatar.dart';
import 'popup_menu.dart';

class RecentCallItem extends StatelessWidget {
  final CallRecord callRecord;

  final VoidCallback onCallPressed;
  final VoidCallback onCopyPressed;

  const RecentCallItem({
    Key? key,
    required this.callRecord,
    required this.onCopyPressed,
    required this.onCallPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _RecentCallItemContainer(
      callRecord: callRecord,
      onCopyPressed: onCopyPressed,
      onCallPressed: onCallPressed,
      child: _RecentCallItemBody(
        title: _RecentCallItemTitle(callRecord),
        subtitle: _RecentItemSubtitle(callRecord),
      ),
    );
  }
}

class _RecentCallItemTitle extends StatelessWidget {
  final CallRecord callRecord;

  const _RecentCallItemTitle(this.callRecord);

  @override
  Widget build(BuildContext context) {
    if (callRecord.renderType == CallRecordRenderType.internalCall) {
      return Row(
        children: [
          Text(context.msg.main.recent.list.item.client.internal.title),
          _WidthAdjustedText(callRecord.caller.number),
          const Text(' & '),
          _WidthAdjustedText(callRecord.destination.number),
        ],
      );
    }

    return Text(callRecord.displayLabel);
  }
}

class _WidthAdjustedText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const _WidthAdjustedText(
    this.text, {
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }
}

class _RecentCallItemBody extends StatelessWidget {
  final Widget title;
  final Widget subtitle;

  const _RecentCallItemBody({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        const SizedBox(height: 2),
        subtitle,
      ],
    );
  }
}

class _RecentCallItemContainer extends StatelessWidget {
  final CallRecord callRecord;

  final VoidCallback onCallPressed;
  final VoidCallback onCopyPressed;

  final Widget child;

  const _RecentCallItemContainer({
    required this.callRecord,
    required this.onCopyPressed,
    required this.onCallPressed,
    required this.child,
  });

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
      leading: !callRecord.isClientCall
          ? Avatar(
              name: callRecord.displayLabel,
              backgroundColor: calculateColorForPhoneNumber(
                context,
                callRecord.thirdPartyNumber,
              ),
              showFallback: callRecord is CallRecordWithContact
                  ? (callRecord as CallRecordWithContact)
                          .contact
                          ?.displayName ==
                      null
                  : false,
              image: callRecord is CallRecordWithContact
                  ? (callRecord as CallRecordWithContact).contact?.avatar
                  : null,
              fallback: const Text('#'),
            )
          : null,
      title: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onCallPressed,
        child: child,
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
    if (callRecord.renderType == CallRecordRenderType.internalCall) {
      return FontAwesomeIcons.arrowRightArrowLeft;
    }

    if (callRecord.isIncomingAndAnsweredElsewhere) {
      return FontAwesomeIcons.arrowTrendDown;
    }

    if (callRecord.wasMissed && callRecord.direction == Direction.inbound) {
      return FontAwesomeIcons.xmark;
    }

    return callRecord.isOutbound
        ? FontAwesomeIcons.arrowUpRight
        : FontAwesomeIcons.arrowDownLeft;
  }

  Color _iconColor(BuildContext context) {
    if (callRecord.renderType == CallRecordRenderType.internalCall) {
      return context.brand.theme.colors.answeredElsewhere;
    }

    if (callRecord.wasMissed && callRecord.direction == Direction.inbound) {
      return Colors.red;
    }

    if (callRecord.isIncomingAndAnsweredElsewhere) {
      return context.brand.theme.colors.answeredElsewhere;
    }

    return context.brand.theme.colors.green1;
  }

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      _icon(context),
      color: _iconColor(context),
      size: 16,
    );

    return Column(
      children: [
        Row(
          children: <Widget>[
            if (callRecord.isIncomingAndAnsweredElsewhere)
              Mirrored(
                child: icon,
              )
            else
              icon,
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

  String? _buildClientCallSubjectText(BuildContext context) {
    switch (callRecord.renderType) {
      case CallRecordRenderType.incomingMissedNoColleagueCall:
      case CallRecordRenderType.incomingMissedColleagueCall:
      case CallRecordRenderType.incomingAnsweredNoColleagueCall:
      case CallRecordRenderType.incomingAnsweredColleagueCall:
        return callRecord.destination.label;

      case CallRecordRenderType.outgoingNoColleagueCall:
      case CallRecordRenderType.outgoingColleagueCall:
        return callRecord.caller.label;

      case CallRecordRenderType.incomingAnsweredLoggedInUserCall:
      case CallRecordRenderType.incomingMissedLoggedInUserCall:
      case CallRecordRenderType.outgoingLoggedInUserCall:
        return context.msg.main.recent.list.item.client.currentUser;
      default:
        return null;
    }
  }

  String _buildClientCallText(BuildContext context) {
    switch (callRecord.renderType) {
      case CallRecordRenderType.incomingMissedNoColleagueCall:
      case CallRecordRenderType.incomingMissedColleagueCall:
      case CallRecordRenderType.incomingMissedLoggedInUserCall:
        return context.msg.main.recent.list.item.client.incomingMissedCall(
          _time,
        );
      case CallRecordRenderType.incomingAnsweredNoColleagueCall:
      case CallRecordRenderType.incomingAnsweredColleagueCall:
      case CallRecordRenderType.incomingAnsweredLoggedInUserCall:
        return context.msg.main.recent.list.item.client.incomingAnsweredCall(
          _time,
          _duration,
        );
      case CallRecordRenderType.outgoingNoColleagueCall:
      case CallRecordRenderType.outgoingColleagueCall:
      case CallRecordRenderType.outgoingLoggedInUserCall:
        return context.msg.main.recent.list.item.client.outgoingCall(
          _time,
          _duration,
        );
      case CallRecordRenderType.internalCall:
        return context.msg.main.recent.list.item.client.internal.subtitle(
          _time,
          _duration,
        );
      default:
        return '';
    }
  }

  String _text(BuildContext context) {
    if (callRecord.isInbound) {
      if (callRecord.wasMissed) {
        return context.msg.main.recent.list.item.wasMissed(_time);
      } else {
        return context.msg.main.recent.list.item.inbound(_time, _duration);
      }
    }

    if (callRecord.isOutbound) {
      return context.msg.main.recent.list.item.outbound(_time, _duration);
    }

    return '$_time - $_duration';
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: context.brand.theme.colors.grey4,
      fontSize: 12,
    );

    if (callRecord.isClientCall) {
      final subject = _buildClientCallSubjectText(context);

      return Row(
        children: [
          if (subject != null) ...[
            _WidthAdjustedText(
              subject,
              style: textStyle,
            ),
            const Text(' '),
          ],
          Text(
            _buildClientCallText(context),
            style: textStyle,
          ),
        ],
      );
    }

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

extension CallDestinationLabel on CallRecord {
  String get displayLabel {
    final callRecord = this;

    if (callRecord is CallRecordWithContact) {
      final contact = callRecord.contact;

      // We always want to prioritize a local contact in the user's phone.
      if (contact != null) return contact.displayName;
    }

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
    final date = DateFormat.yMd(Platform.localeName).format(headerDate);
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

/// These represents all the different states a call record can be in that
/// require specific rendering rules.
///
/// Any thing that doesn't require specific render should be
/// [CallRecordRenderType.other].
///
/// See [CallRecord.renderType]
enum CallRecordRenderType {
  incomingMissedNoColleagueCall,
  incomingMissedColleagueCall,
  incomingMissedLoggedInUserCall,
  incomingAnsweredNoColleagueCall,
  incomingAnsweredColleagueCall,
  incomingAnsweredLoggedInUserCall,
  outgoingNoColleagueCall,
  outgoingColleagueCall,
  outgoingLoggedInUserCall,
  internalCall,
  other,
}

extension RenderType on CallRecord {
  bool get isClientCall => this is ClientCallRecord;

  /// See [CallRecordRenderType]
  CallRecordRenderType get renderType {
    final callRecord = this;

    if (callRecord is ClientCallRecord) {
      return callRecord.renderType;
    }

    return CallRecordRenderType.other;
  }
}

extension ClientRenderType on ClientCallRecord {
  CallRecordRenderType get renderType {
    if (callType == CallType.colleague) {
      return CallRecordRenderType.internalCall;
    }

    if (direction == Direction.inbound && !answered) {
      if (didTargetColleague) {
        return CallRecordRenderType.incomingMissedColleagueCall;
      } else if (didTargetLoggedInUser) {
        return CallRecordRenderType.incomingMissedLoggedInUserCall;
      } else {
        return CallRecordRenderType.incomingMissedNoColleagueCall;
      }
    }

    if (direction == Direction.inbound && answered) {
      if (didTargetColleague) {
        return CallRecordRenderType.incomingAnsweredColleagueCall;
      } else if (didTargetLoggedInUser) {
        return CallRecordRenderType.incomingAnsweredLoggedInUserCall;
      } else {
        return CallRecordRenderType.incomingAnsweredNoColleagueCall;
      }
    }

    if (direction == Direction.outbound) {
      if (wasInitiatedByColleague) {
        return CallRecordRenderType.outgoingColleagueCall;
      } else if (wasInitiatedByLoggedInUser) {
        return CallRecordRenderType.outgoingLoggedInUserCall;
      } else {
        return CallRecordRenderType.outgoingNoColleagueCall;
      }
    }

    return CallRecordRenderType.other;
  }
}

class Mirrored extends StatelessWidget {
  final Widget child;

  const Mirrored({required this.child});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: -1,
      child: child,
    );
  }
}
