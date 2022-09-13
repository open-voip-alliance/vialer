import 'package:dartx/dartx.dart';
import 'package:equatable/equatable.dart';

class Colleague extends Equatable {
  final int id;
  final String name;
  final ColleagueAvailabilityStatus status;
  final ColleagueDestination destination;

  /// A list of [ColleagueContext] events that are relevant to this colleague.
  ///
  /// These are sorted in order of priority with the first in the list
  /// representing the most recent/relevant.
  final List<ColleagueContext> context;

  /// The most relevant/recent context event. For example, if the user is
  /// in a meeting (NYI) but also in a call, then this would show them as being
  /// in a call even if the meeting is more recent.
  ColleagueContext? get mostRelevantContext => context.firstOrNull;

  const Colleague({
    required this.id,
    required this.name,
    required this.status,
    required this.context,
    required this.destination,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        status,
        context,
        destination,
      ];
}

/// A single status that represents the availability of the colleague.
enum ColleagueAvailabilityStatus {
  available,
  doNotDisturb,
  busy,

  /// An unknown status is when, for example, the user has an app account
  /// for their user but they are not currently SIP registered anywhere. It
  /// essentially means they are likely available on mobile but we cannot
  /// know for sure.
  unknown,

  /// A user will only appear as offline when they don't have an app account
  /// linked to their user AND they are not SIP registered anywhere.
  offline,
}

/// The destination that we can call to reach the given colleague.
class ColleagueDestination extends Equatable {
  final int id;
  final String number;
  final ColleagueDestinationType type;

  const ColleagueDestination({
    required this.id,
    required this.number,
    required this.type,
  });

  @override
  List<Object?> get props => [
        id,
        number,
        type,
      ];
}

enum ColleagueDestinationType {
  app,
  webphone,
  voipAccount,
  fixed,
}

/// Represents a possible event that the colleague has currently performed,
/// (e.g. that their phone is currently ringing), including any
/// associated relevant data (e.g. the number that is calling them).
abstract class ColleagueContext {
  const ColleagueContext();
}

abstract class ColleagueContextCalling extends ColleagueContext {
  final String thirdParty;

  const ColleagueContextCalling({required this.thirdParty});
}

class ColleagueContextRinging extends ColleagueContextCalling {
  const ColleagueContextRinging({required super.thirdParty});
}

class ColleagueContextInCall extends ColleagueContextCalling {
  const ColleagueContextInCall({required super.thirdParty});
}
