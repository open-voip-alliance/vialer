import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../app/util/json_converter.dart';
import 'destination.dart';
import 'voipgrid_destination.dart';

part 'voipgrid_phone_account.freezed.dart';

part 'voipgrid_phone_account.g.dart';

@freezed
class VoipgridPhoneAccount extends VoipgridDestination
    with _$VoipgridPhoneAccount {
  const factory VoipgridPhoneAccount({
    @JsonKey(name: 'account_id') required int accountId,
    @JsonKey(name: 'internal_number') required int internalNumber,
    @override required String description,
    required String password,
    @override @JsonIdConverter() int? id,
  }) = _VoipgridPhoneAccount;

  const VoipgridPhoneAccount._();

  factory VoipgridPhoneAccount.fromJson(Map<String, dynamic> json) =>
      _$VoipgridPhoneAccountFromJson(json);

  @override
  Destination toDestination() => Destination.phoneAccount(
        id!,
        description,
        accountId,
        internalNumber,
      );
}
