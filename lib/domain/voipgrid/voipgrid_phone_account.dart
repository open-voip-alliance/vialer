import 'package:json_annotation/json_annotation.dart';

import '../../app/util/json_converter.dart';
import '../calling/voip/destination.dart';
import 'voipgrid_destination.dart';

part 'voipgrid_phone_account.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class VoipgridPhoneAccount extends VoipgridDestination {
  @override
  @JsonIdConverter()
  final int? id;

  final int accountId;

  final int internalNumber;

  @override
  final String description;

  final String password;

  const VoipgridPhoneAccount({
    required this.id,
    required this.accountId,
    required this.internalNumber,
    required this.description,
    required this.password,
  });

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
