import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../user/user.dart';
import 'destination.dart';

part 'destinations.freezed.dart';
part 'destinations.g.dart';

@freezed
class Destinations with _$Destinations {
  const Destinations._();

  const factory Destinations({
    required Destination activeDestination,
    required List<Destination> availableDestinations,
    required int internalNumber,
    required int selectedDestinationId,
  }) = _Destinations;

  factory Destinations.fromJson(dynamic json) =>
      _$DestinationsFromJson(json as Map<String, dynamic>);

  static Map<String, dynamic> serializeToJson(Destinations destinations) =>
      destinations.toJson();

  List<PhoneAccount> get phoneAccounts =>
      availableDestinations.whereType<PhoneAccount>().toList();

  /// Find the app account for the given user. This should never be null
  /// with a user properly configured for the app.
  PhoneAccount? findAppAccountFor({required User user}) =>
      phoneAccounts.firstOrNullWhere(
        (phoneAccount) => user.appAccountId == phoneAccount.id.toString(),
      );
}
