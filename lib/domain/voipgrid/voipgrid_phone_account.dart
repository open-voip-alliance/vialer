import 'package:freezed_annotation/freezed_annotation.dart';

import '../../app/util/json_converter.dart';
import '../calling/voip/destination.dart';
import 'voipgrid_destination.dart';

part 'voipgrid_phone_account.freezed.dart';
part 'voipgrid_phone_account.g.dart';

@freezed
@JsonSerializable(fieldRename: FieldRename.snake)
class VoipgridPhoneAccount extends VoipgridDestination
    with _$VoipgridPhoneAccount {
  const factory VoipgridPhoneAccount({
    @override @JsonIdConverter() int? id,
    required int accountId,
    required int internalNumber,
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
