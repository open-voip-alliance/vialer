// ignore_for_file: unused_element
import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:vialer/domain/voipgrid/voipgrid_service.dart';

import '../../calling/voip/destination.dart';

part 'user_details.freezed.dart';
part 'user_details.g.dart';

@injectable
class UserDetailsRepository {
  UserDetailsRepository(this._service);

  final VoipgridService _service;

  Future<UserDetails> getUserDetails() => _service
      .getUserDetails()
      .then((response) => UserDetails.fromJson(response.body!));
}

@freezed
class UserDetails with _$UserDetails {
  const UserDetails._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserDetails({
    required String firstName,
    required String lastName,
    String? preposition,
    required String internalNumber,
    _SelectedDestination? selectedDestination,
    _AppAccount? app,
    _WebphoneAccount? webphone,
    required _Destinations destinations,
  }) = _UserDetails;

  factory UserDetails.fromJson(Map<String, dynamic> json) =>
      _$UserDetailsFromJson(json);

  List<Destination> get availableDestinations => [
        ...destinations.fixedDestinations,
        ...destinations.voipAccounts,
      ].map((e) => e.toDestination()).toList();
}

@freezed
class _AppAccount with _$_AppAccount {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory _AppAccount({
    String? mobileNumber,
    required bool useMobileNumberAsFallback,
    _VoipAccountDestination? voipAccount,
  }) = __AppAccount;

  factory _AppAccount.fromJson(Map<String, dynamic> json) =>
      _$_AppAccountFromJson(json);
}

@freezed
class _WebphoneAccount with _$_WebphoneAccount {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory _WebphoneAccount({
    _VoipAccountDestination? voipAccount,
  }) = __WebphoneAccount;

  factory _WebphoneAccount.fromJson(Map<String, dynamic> json) =>
      _$_WebphoneAccountFromJson(json);
}

@freezed
class _Destinations with _$_Destinations {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory _Destinations({
    @Default([]) Iterable<_VoipAccountDestination> voipAccounts,
    @Default([]) Iterable<_FixedDestination> fixedDestinations,
  }) = __Destinations;

  factory _Destinations.fromJson(Map<String, dynamic> json) =>
      _$_DestinationsFromJson(json);
}

@freezed
sealed class _Destination with _$_Destination {
  const _Destination._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory _Destination.voipAccount({
    required String id,
    required String uuid,
    required String accountId,
    required String description,
    required String internalNumber,
    required String status,
  }) = _VoipAccountDestination;

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory _Destination.fixed({
    required String id,
    required String uuid,
    required String phoneNumber,
    required String description,
  }) = _FixedDestination;

  Destination toDestination() => map(
        voipAccount: (voipAccount) => Destination.phoneAccount(
          voipAccount.id.toInt(),
          voipAccount.description,
          voipAccount.accountId.toInt(),
          voipAccount.internalNumber.toInt(),
        ),
        fixed: (fixed) => Destination.phoneNumber(
          fixed.id.toInt(),
          fixed.description,
          fixed.phoneNumber,
        ),
      );

  factory _Destination.fromJson(Map<String, dynamic> json) =>
      _$_DestinationFromJson(json);
}

@freezed
class _SelectedDestination with _$_SelectedDestination {
  const _SelectedDestination._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory _SelectedDestination({
    required String id,
    required String uuid,
    _VoipAccountDestination? voipAccount,
    _FixedDestination? fixedDestination,
  }) = __SelectedDestination;

  Destination? asDestination() => [voipAccount, fixedDestination]
      .filterNotNull()
      .firstOrNull
      ?.toDestination();

  factory _SelectedDestination.fromJson(Map<String, dynamic> json) =>
      _$_SelectedDestinationFromJson(json);
}
