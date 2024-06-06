import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart';
import 'package:flutter_phone_lib/src/contacts/contact.dart';
import 'package:vialer/presentation/util/loggable.dart';

import '../../../shared/controllers/caller/cubit.dart';

/// Only builds when the [CallerCubit]'s state is a [CallProcessState].
class CallProcessStateBuilder extends StatelessWidget with Loggable {
  CallProcessStateBuilder({
    required this.builder,
    this.includeCallDurationChanges = false,
    super.key,
  });

  final BlocWidgetBuilder<CallProcessState> builder;
  final bool includeCallDurationChanges;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallerCubit, CallerState>(
      buildWhen: (previous, current) {
        if (current is! CallProcessState) return false;

        if (current.voipCall == null) {
          logger.warning(
            'State is ${current.runtimeType}(CallProcessState) but no active '
            'voip call',
          );
          return false;
        }

        if (previous is CallProcessState &&
            !includeCallDurationChanges &&
            previous.voipCall != null) {
          if (previous.audioState?.currentRoute !=
              current.audioState?.currentRoute)
            return true;
          else
            return !current.voipCall!.compareCalls(previous.voipCall!);
        }

        return previous != current;
      },
      builder: (context, state) => builder(context, state as CallProcessState),
    );
  }
}

extension on Call {
  Call copyWith({
    String? remoteNumber,
    String? displayName,
    CallState? state,
    CallDirection? direction,
    int? duration,
    bool? isOnHold,
    String? uuid,
    double? mos,
    double? currentMos,
    Contact? contact,
    String? remotePartyHeading,
    String? remotePartySubheading,
    String? prettyDuration,
    String? callId,
    String? reason,
  }) {
    return Call(
      remoteNumber: remoteNumber ?? this.remoteNumber,
      displayName: displayName ?? this.displayName,
      state: state ?? this.state,
      direction: direction ?? this.direction,
      duration: duration ?? this.duration,
      isOnHold: isOnHold ?? this.isOnHold,
      uuid: uuid ?? this.uuid,
      mos: mos ?? this.mos,
      currentMos: currentMos ?? this.currentMos,
      contact: contact ?? this.contact,
      remotePartyHeading: remotePartyHeading ?? this.remotePartyHeading,
      remotePartySubheading:
          remotePartySubheading ?? this.remotePartySubheading,
      prettyDuration: prettyDuration ?? this.prettyDuration,
      callId: callId ?? this.callId,
      reason: reason ?? this.reason,
    );
  }

  ///This will compare two Call objects while ignoring duration, prettyDuration,
  ///uuid, mos and currentMos properties.
  bool compareCalls(Call other) {
    final thisCall = copyWith(
      duration: 0,
      prettyDuration: '',
      uuid: '',
      mos: 0,
      currentMos: 0,
    );

    final otherCall = other.copyWith(
      duration: 0,
      prettyDuration: '',
      uuid: '',
      mos: 0,
      currentMos: 0,
    );

    return thisCall == otherCall;
  }
}
