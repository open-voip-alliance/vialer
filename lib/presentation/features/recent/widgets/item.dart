import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vialer/presentation/resources/theme.dart';
import 'package:vialer/presentation/util/phone_number.dart';

import '../../../../../data/models/call_records/call_record.dart';
import '../../../resources/localizations.dart';
import '../../../shared/widgets/avatar.dart';
import '../../../util/color.dart';
import '../../../util/contact.dart';
import 'popup_menu.dart';

class RecentCallItem extends StatelessWidget {
  const RecentCallItem({
    required this.callRecord,
    required this.onCopyPressed,
    required this.onCallPressed,
    super.key,
  });

  final CallRecord callRecord;

  final VoidCallback onCallPressed;
  final VoidCallback onCopyPressed;

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
  const _RecentCallItemTitle(this.callRecord);

  final CallRecord callRecord;

  bool get _shouldRenderAsInternalCall =>
      callRecord.renderType == CallRecordRenderType.internalCall &&
      callRecord is ClientCallRecordWithContact;

  @override
  Widget build(BuildContext context) {
    final callRecord = this.callRecord;

    if (_shouldRenderAsInternalCall) {
      return _InternalCall(callRecord as ClientCallRecordWithContact);
    }

    return PhoneNumberText(child: Text(callRecord.displayLabel));
  }
}

class _InternalCall extends StatelessWidget {
  const _InternalCall(this.callRecord);

  final ClientCallRecordWithContact callRecord;

  String _callPartyText({
    required String number,
    String? name,
  }) =>
      name.isNullOrBlank ? number : '$name ($number)';

  @override
  Widget build(BuildContext context) {
    final prefix = context.msg.main.recent.list.item.client.internal.title;

    final caller = _callPartyText(
      number: callRecord.destination.number,
      name: callRecord.destinationContact?.displayName ??
          callRecord.destination.name,
    );

    final destination = _callPartyText(
      number: callRecord.caller.number,
      name: callRecord.callerContact?.displayName ?? callRecord.caller.name,
    );

    return Row(
      children: [
        Flexible(
          child: PhoneNumberText(
            child: Text(
              '$prefix $caller & $destination',
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _WidthAdjustedText extends StatelessWidget {
  const _WidthAdjustedText(
    this.text, {
    this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: PhoneNumberText(
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      ),
    );
  }
}

class _RecentCallItemBody extends StatelessWidget {
  const _RecentCallItemBody({
    required this.title,
    required this.subtitle,
  });

  final Widget title;
  final Widget subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
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
  const _RecentCallItemContainer({
    required this.callRecord,
    required this.onCopyPressed,
    required this.onCallPressed,
    required this.child,
  });

  final CallRecord callRecord;

  final VoidCallback onCallPressed;
  final VoidCallback onCopyPressed;

  final Widget child;

  void _onPopupMenuItemPress(RecentCallMenuAction action) {
    switch (action) {
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

  static void _emptyOnTapToKeepSplash() {}

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: !callRecord.isClientCall ? _RecentItemAvatar(callRecord) : null,
      title: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onCallPressed,
        child: child,
        excludeFromSemantics: true,
      ),
      onTap: _emptyOnTapToKeepSplash,
      trailing: RecentItemPopupMenu(
        callRecord: callRecord,
        onPopupMenuItemPress: _onPopupMenuItemPress,
      ),
    );
  }
}

class _RecentItemAvatar extends StatelessWidget {
  const _RecentItemAvatar(this.callRecord);

  final CallRecord callRecord;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Avatar(
        name: callRecord.displayLabel,
        backgroundColor: calculateColorForPhoneNumber(
          context,
          callRecord.thirdPartyNumber,
        ),
        showFallback: callRecord is CallRecordWithContact &&
            (callRecord as CallRecordWithContact).contact?.displayName == null,
        image: callRecord is CallRecordWithContact
            ? (callRecord as CallRecordWithContact).contact?.avatar
            : null,
        fallback: const Text('#'),
      ),
    );
  }
}

class _RecentItemSubtitle extends StatelessWidget {
  const _RecentItemSubtitle(this.callRecord);

  final CallRecord callRecord;

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
              _Mirrored(
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
  const _RecentItemSubtitleText(this.callRecord);

  final CallRecord callRecord;

  String get _time => DateFormat.Hm().format(callRecord.date.toLocal());

  String get _duration => prettyDuration(
        callRecord.duration,
        abbreviated: true,
        delimiter: ' ',
        spacer: '',
      );

  String get _durationForSemantics => prettyDuration(
        callRecord.duration,
        abbreviated: false,
        delimiter: ' ',
        spacer: ' ',
      );

  String _callPartyText(CallParty party) {
    if (party.name == null ||
        party.name!.isEmpty ||
        party.name == party.number) {
      return party.number;
    } else {
      return party.name!;
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
      case CallRecordRenderType.internalCall:
      case CallRecordRenderType.other:
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
      case CallRecordRenderType.other:
        return '';
    }
  }

  String _text(
    BuildContext context, {
    bool forSemantics = false,
  }) {
    final duration = forSemantics ? _durationForSemantics : _duration;

    if (callRecord.isInbound) {
      if (callRecord.wasMissed) {
        return context.msg.main.recent.list.item.wasMissed(_time);
      } else {
        return context.msg.main.recent.list.item.inbound(_time, duration);
      }
    }

    if (callRecord.isOutbound) {
      return context.msg.main.recent.list.item.outbound(_time, duration);
    }

    return '$_time - $duration';
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
          ),
        ],
      );
    }

    return Text(
      _text(context),
      style: textStyle,
      semanticsLabel: _text(context, forSemantics: true),
    );
  }
}

extension CallDestinationLabel on CallRecord {
  String get displayLabel {
    final callRecord = this;

    final contact = callRecord.map(
      withoutContact: (_) => null,
      withContact: (callRecord) => callRecord.contact,
      client: (_) => null,
      clientWithContact: (record) =>
          isInbound ? record.callerContact : record.destinationContact,
    );

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
  const RecentCallHeader({
    required this.date,
    required this.child,
    this.isFirst = false,
    super.key,
  });

  final DateTime date;
  final bool isFirst;
  final Widget child;

  String _text(
    BuildContext context, {
    required DateTime headerDate,
    bool forSemantics = false,
  }) {
    final dateFormat = forSemantics
        ? DateFormat.yMMMMd(Platform.localeName)
        : DateFormat.yMd(Platform.localeName);
    final date = dateFormat.format(headerDate);
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
    final date = this.date.toLocal();

    final divider = Expanded(
      child: Divider(height: 1, color: color),
    );

    return Semantics(
      explicitChildNodes: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              container: true,
              excludeSemantics: true,
              label: _text(context, headerDate: date, forSemantics: true),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    divider,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _text(context, headerDate: date),
                        style: TextStyle(
                          color: color,
                        ),
                      ),
                    ),
                    divider,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

/// These represents all the different states a call record can be in that
/// require specific rendering rules.
///
/// Any thing that doesn't require specific render should be
/// [CallRecordRenderType.other].
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
  bool get isClientCall =>
      this is ClientCallRecord || this is ClientCallRecordWithContact;

  /// See [CallRecordRenderType]
  CallRecordRenderType get renderType {
    final callRecord = this;

    return callRecord.map(
      withoutContact: (_) => CallRecordRenderType.other,
      withContact: (_) => CallRecordRenderType.other,
      client: (record) => record.renderType,
      clientWithContact: (record) => record.renderType,
    );
  }
}

extension on ClientCallRecord {
  CallRecordRenderType get renderType => withContact(
        callerContact: null,
        destinationContact: null,
      ).renderType;
}

extension ClientRenderType on ClientCallRecordWithContact {
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

class _Mirrored extends StatelessWidget {
  const _Mirrored({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: -1,
      child: child,
    );
  }
}
