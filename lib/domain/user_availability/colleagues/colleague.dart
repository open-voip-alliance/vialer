import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'colleague.freezed.dart';
part 'colleague.g.dart';

@freezed
class Colleague with _$Colleague {
  String? get number => map(
        (colleague) => colleague.destination?.number,
        unconnectedVoipAccount: (voipAccount) => voipAccount.number,
      );

  ColleagueContext? get mostRelevantContext => map(
        (colleague) => colleague.context.firstOrNull,
        unconnectedVoipAccount: (_) => null,
      );

  bool get isAvailableOnMobileAppOrFixedDestination => map(
        (colleague) =>
            const [ColleagueDestinationType.app, ColleagueDestinationType.fixed]
                .contains(colleague.destination?.type) &&
            colleague.status == ColleagueAvailabilityStatus.unknown,
        unconnectedVoipAccount: (_) => false,
      );

  /// This colleague is online, this means their availability is currently
  /// known.
  bool get isOnline => map(
        (colleague) =>
            const [
              ColleagueAvailabilityStatus.available,
              ColleagueAvailabilityStatus.doNotDisturb,
              ColleagueAvailabilityStatus.busy,
            ].contains(colleague.status) ||
            isAvailableOnMobileAppOrFixedDestination,
        unconnectedVoipAccount: (_) => false,
      );

  const Colleague._();

  /// A Voipgrid user which we fully support, including their current
  /// availability and context.
  const factory Colleague({
    required String id,
    required String name,

    /// A list of [ColleagueContext] events that are relevant to this colleague.
    ///
    /// These are sorted in order of priority with the first in the list
    /// representing the most recent/relevant.
    required List<ColleagueContext> context,
    ColleagueAvailabilityStatus? status,

    /// The most relevant/recent context event. For example, if the user is
    /// in a meeting (NYI) but also in a call, then this would show them as
    /// being in a call even if the meeting is more recent.
    ColleagueDestination? destination,
  }) = _Colleague;

  /// A voip account that is not connected to any user, we do not get
  /// information about their current availability, they only exist for the
  /// user to be able to see and call them.
  const factory Colleague.unconnectedVoipAccount({
    required String id,
    required String name,
    required String number,
  }) = UnconnectedVoipAccount;

  factory Colleague.fromJson(Map<String, dynamic> json) =>
      _$ColleagueFromJson(json);
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
  offline;

  static ColleagueAvailabilityStatus fromServerValue(String? value) {
    switch (value) {
      case 'do_not_disturb':
        return ColleagueAvailabilityStatus.doNotDisturb;
      case 'offline':
        return ColleagueAvailabilityStatus.offline;
      case 'available':
        return ColleagueAvailabilityStatus.available;
      case 'busy':
        return ColleagueAvailabilityStatus.busy;
      default:
        return ColleagueAvailabilityStatus.unknown;
    }
  }
}

/// The destination that we can call to reach the given colleague.
@freezed
class ColleagueDestination with _$ColleagueDestination {
  const factory ColleagueDestination({
    required String number,
    required ColleagueDestinationType type,
  }) = _ColleagueDestination;

  factory ColleagueDestination.fromJson(Map<String, dynamic> json) =>
      _$ColleagueDestinationFromJson(json);
}

enum ColleagueDestinationType {
  app,
  voipAccount,
  fixed,
  none;

  static ColleagueDestinationType fromServerValue(String? value) {
    switch (value) {
      case 'app_account':
        return ColleagueDestinationType.app;
      case 'voip_account':
        return ColleagueDestinationType.voipAccount;
      case 'fixeddestination':
        return ColleagueDestinationType.fixed;
      default:
        return ColleagueDestinationType.none;
    }
  }
}

/// Represents a possible event that the colleague has currently performed,
/// (e.g. that their phone is currently ringing), including any
/// associated relevant data (e.g. the number that is calling them).
@freezed
class ColleagueContext with _$ColleagueContext {
  const factory ColleagueContext.ringing() = Ringing;
  const factory ColleagueContext.inCall() = InCall;

  factory ColleagueContext.fromJson(Map<String, dynamic> json) =>
      _$ColleagueContextFromJson(json);

  static ColleagueContext? fromServerValue(String? value) {
    switch (value) {
      case 'in_call':
        return const ColleagueContext.inCall();
      case 'ringing':
        return const ColleagueContext.ringing();
      default:
        return null;
    }
  }

  const ColleagueContext._();
}
