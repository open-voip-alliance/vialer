import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'colleague.freezed.dart';

@freezed
class Colleague with _$Colleague {
  ColleagueContext? get mostRelevantContext => map(
        (colleague) => colleague.context.firstOrNull,
        unconnectedVoipAccount: (_) => null,
      );

  const Colleague._();

  /// A Voipgrid user which we fully support, including their current
  /// availability and context.
  const factory Colleague({
    required String id,
    required String name,
    required ColleagueAvailabilityStatus status,

    /// A list of [ColleagueContext] events that are relevant to this colleague.
    ///
    /// These are sorted in order of priority with the first in the list
    /// representing the most recent/relevant.
    required List<ColleagueContext> context,

    /// The most relevant/recent context event. For example, if the user is
    /// in a meeting (NYI) but also in a call, then this would show them as
    /// being in a call even if the meeting is more recent.
    required ColleagueDestination destination,
  }) = _Colleague;

  /// A voip account that is not connected to any user, we do not get
  /// information about their current availability, they only exist for the
  /// user to be able to see and call them.
  const factory Colleague.unconnectedVoipAccount({
    required String id,
    required String name,
    required String number,
  }) = UnconnectedVoipAccount;
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
@freezed
class ColleagueDestination with _$ColleagueDestination {
  const factory ColleagueDestination({
    required String id,
    required String number,
    required ColleagueDestinationType type,
  }) = _ColleagueDestination;
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
@freezed
class ColleagueContext with _$ColleagueContext {
  const factory ColleagueContext.ringing(String number) = Ringing;
  const factory ColleagueContext.inCall(String number) = InCall;
}
