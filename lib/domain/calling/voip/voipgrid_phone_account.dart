import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../app/util/json_converter.dart';
import 'destination.dart';
import 'voipgrid_destination.dart';

part 'voipgrid_phone_account.freezed.dart';
part 'voipgrid_phone_account.g.dart';

@freezed
class VoipgridPhoneAccount extends VoipgridDestination
    with _$VoipgridPhoneAccount {
  const VoipgridPhoneAccount._();

  const factory VoipgridPhoneAccount({
    @override @JsonIdConverter() int? id,
    @JsonKey(name: 'account_id') required int accountId,
    @JsonKey(name: 'internal_number') required int internalNumber,
    @override required String description,
    required String password,
  }) = _VoipgridPhoneAccount;

  factory VoipgridPhoneAccount.fromJson(Map<String, dynamic> json) =>
      _$VoipgridPhoneAccountFromJson(json);

  @override
  Destination toDestination() => Destination.phoneAccount(
        id,
        description,
        accountId,
        internalNumber,
      );
}
