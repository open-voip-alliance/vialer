import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vialer/dependency_locator.dart';
import 'package:vialer/domain/calling/voip/destination_repository.dart';

import '../../user/user.dart';

part 'destination.freezed.dart';
part 'destination.g.dart';

@freezed
sealed class Destination with _$Destination {
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
    int internalNumber, {
    @Default(true) bool isOnline,
  }) = PhoneAccount;

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

  List<Destination> withoutAccountsFor(User user) => (toList()
    ..remove(findAppAccountFor(user: user))
    ..remove(findWebphoneAccountFor(user: user)));

  List<PhoneAccount> deskPhonesFor({required User user}) =>
      withoutAccountsFor(user).whereType<PhoneAccount>().toList();

  List<PhoneNumber> fixedDestinationsFor({required User user}) =>
      withoutAccountsFor(user).whereType<PhoneNumber>().toList();

  PhoneAccount? findAppAccountFor({required User user}) =>
      _findPhoneAccountById(user.appAccountId);

  PhoneAccount? findWebphoneAccountFor({required User user}) =>
      _findPhoneAccountById(user.webphoneAccountId);

  Destination? findHighestPriorityDestinationFor({required User user}) {
    final appAccount = findAppAccountFor(user: user);
    if (appAccount != null) return appAccount;

    final webphoneAccount = findWebphoneAccountFor(user: user);
    if (webphoneAccount != null) return webphoneAccount;

    final deskPhoneAccount = deskPhonesFor(user: user).firstOrNull;
    if (deskPhoneAccount != null) return deskPhoneAccount;

    final fixedDestination = fixedDestinationsFor(user: user).firstOrNull;
    if (fixedDestination != null) return fixedDestination;

    return null;
  }

  PhoneAccount? _findPhoneAccountById(String? id) {
    if (id == null) return null;

    final destinations = this;

    return destinations.phoneAccounts.firstOrNullWhere(
      (phoneAccount) => id == phoneAccount.id.toString(),
    );
  }
}

extension IsOnline on Destination {
  bool get isOnline => map(
        unknown: (_) => true,
        notAvailable: (_) => true,
        phoneNumber: (_) => true,
        phoneAccount: (phoneAccount) => phoneAccount.isOnline,
      );
}

extension UserDestinationLookUp on Destination {
  // As we are now updating the destination objects with the [isOnline]
  // status, it is no longer possible to check for equality between
  // the user's destination and a destination stored in the list. So for now
  // this will just look-up the object in the list to make sure they can
  // be checked for equality. There is a ticket to resolve this so there
  // is only a single source of truth: #1751.
  Destination toDestinationObject() {
    final destinations =
        dependencyLocator<DestinationRepository>().availableDestinations;

    final destination = switch (this) {
      Unknown() => this,
      NotAvailable() => this,
      PhoneAccount phoneAccount => destinations
          .whereType<PhoneAccount>()
          .where((element) => element.accountId == phoneAccount.accountId)
          .firstOrNull,
      PhoneNumber phoneNumber => destinations
          .whereType<PhoneNumber>()
          .where((element) => phoneNumber.id == phoneNumber.id)
          .firstOrNull,
    };

    assert(
      destination != null,
      "User's destination should always be in our destination list",
    );

    return destination != null ? destination : this;
  }
}
