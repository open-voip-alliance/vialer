import 'package:json_annotation/json_annotation.dart';
import '../../app/util/json_converter.dart';

import 'destination.dart';

part 'phone_account.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PhoneAccount extends Destination {
  @override
  @JsonIdConverter()
  final int id;

  final int accountId;

  final int internalNumber;

  @override
  final String description;

  final String password;

  const PhoneAccount({
    this.id,
    this.accountId,
    this.internalNumber,
    this.description,
    this.password,
  });

  PhoneAccount copyWith({
    int id,
    int accountId,
    int internalNumber,
    String description,
    String password,
  }) {
    return PhoneAccount(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      internalNumber: internalNumber ?? this.internalNumber,
      description: description ?? this.description,
      password: password ?? this.password,
    );
  }

  factory PhoneAccount.fromJson(Map<String, dynamic> json) =>
      _$PhoneAccountFromJson(json);

  Map<String, dynamic> toJson() => _$PhoneAccountToJson(this);

  @override
  String toString() => '$runtimeType(id: $id, $internalNumber, $description)';

  @override
  List<Object> get props => [
        ...super.props,
        id,
        accountId,
        internalNumber,
        description,
        password,
      ];
}
