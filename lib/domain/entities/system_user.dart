import 'package:dartx/dartx.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'system_user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SystemUser extends Equatable {
  final String uuid;

  final String email;

  @JsonKey(name: 'mobile_nr')
  final String? mobileNumber;

  final String firstName;
  final String lastName;

  final String token;

  @JsonKey(name: 'app_account')
  final Uri? appAccountUrl;

  final String? outgoingCli;

  String? get appAccountId => appAccountUrl?.pathSegments.lastOrNullWhere(
        (p) => p.isNotEmpty,
      );

  bool get isOutgoingCliSuppressed => outgoingCli?.isSuppressed ?? false;

  /// This is only nullable for backwards compatibility, it can be made
  /// non-nullable in a future update.
  @JsonKey(name: 'client')
  final Uri? clientUrl;

  String? get clientId => clientUrl?.pathSegments.lastOrNullWhere(
        (p) => p.isNotEmpty,
      );

  const SystemUser({
    required this.uuid,
    required this.email,
    this.mobileNumber,
    required this.firstName,
    required this.lastName,
    required this.token,
    this.appAccountUrl,
    this.outgoingCli,
    this.clientUrl,
  });

  SystemUser copyWith({
    String? uuid,
    String? email,
    String? mobileNumber,
    String? firstName,
    String? lastName,
    String? token,
    Uri? appAccountUrl,
    String? outgoingCli,
    Uri? clientUrl,
  }) {
    return SystemUser(
      uuid: uuid ?? this.uuid,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      token: token ?? this.token,
      appAccountUrl: appAccountUrl ?? this.appAccountUrl,
      outgoingCli: outgoingCli ?? this.outgoingCli,
      clientUrl: clientUrl ?? this.clientUrl,
    );
  }

  factory SystemUser.fromJson(Map<String, dynamic> json) =>
      _$SystemUserFromJson(json);

  Map<String, dynamic> toJson() => _$SystemUserToJson(this);

  @override
  List<Object?> get props => [
        uuid,
        email,
        mobileNumber,
        firstName,
        lastName,
        token,
        appAccountUrl,
        outgoingCli,
        clientUrl,
      ];
}

extension Suppressed on String {
  bool get isSuppressed => this == 'suppressed';
}
