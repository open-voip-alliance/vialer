import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../user/user.dart';

part 'destination.freezed.dart';
part 'destination.g.dart';

@freezed
class Destination with _$Destination {
  const factory Destination.unknown() = Unknown;

  const factory Destination.notAvailable() = NotAvailable;

  // Formally known as FixedDestination.
  const factory Destination.phoneNumber(
    int? id,
    String? description,
    String? phoneNumber,
  ) = PhoneNumber;

  const factory Destination.phoneAccount(
    int? id,
    String description,
    int accountId,
    int internalNumber,
  ) = PhoneAccount;

  factory Destination.fromJson(dynamic json) =>
      _$DestinationFromJson(json as Map<String, dynamic>);

  static Map<String, dynamic> serializeToJson(Destination destination) =>
      destination.toJson();
}

extension DestinationsList on List<Destination> {
  List<PhoneAccount> get phoneAccounts {
    final destinations = this;
    return destinations.whereType<PhoneAccount>().toList();
  }

  PhoneAccount? findAppAccountFor({required User user}) {
    final destinations = this;

    return destinations.phoneAccounts.firstOrNullWhere(
      (phoneAccount) => user.appAccountId == phoneAccount.id.toString(),
    );
  }
}
