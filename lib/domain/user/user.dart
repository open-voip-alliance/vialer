import 'package:dartx/dartx.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../voipgrid/user_voip_config.dart';
import 'client.dart';
import 'permissions/user_permissions.dart';
import 'settings/settings.dart';

part 'user.g.dart';

@immutable
@JsonSerializable()
class User extends Equatable {
  final String uuid;

  final String email;

  final String firstName;
  final String lastName;

  String get fullName => '$firstName $lastName';

  final String? token;

  final Uri? appAccountUrl;

  String? get appAccountId => appAccountUrl?.pathSegments.lastOrNullWhere(
        (p) => p.isNotEmpty,
      );

  @JsonKey(toJson: Client.toJson, fromJson: Client.fromJson)
  final Client client;

  @JsonKey(
    toJson: UserVoipConfig.serializeToJson,
    fromJson: UserVoipConfig.serializeFromJson,
  )
  final UserVoipConfig? voip;

  @JsonKey(toJson: Settings.toJson, fromJson: Settings.fromJson)
  final Settings settings;

  @JsonKey(
    toJson: UserPermissions.serializeToJson,
    fromJson: UserPermissions.fromJson,
  )
  final UserPermissions permissions;

  User({
    required this.uuid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.token,
    this.appAccountUrl,
    required this.client,
    this.voip,
    required this.settings,
    this.permissions = const UserPermissions(),
  });

  User copyWith({
    String? uuid,
    String? email,
    String? firstName,
    String? lastName,
    String? token,
    Uri? appAccountUrl,
    Client? client,
    UserVoipConfig? voip,
    Settings? settings,
    UserPermissions? permissions,
  }) {
    return User(
      uuid: uuid ?? this.uuid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      token: token ?? this.token,
      appAccountUrl: appAccountUrl ?? this.appAccountUrl,
      client: client ?? this.client,
      voip: voip ?? this.voip,
      settings: settings ?? this.settings,
      permissions: permissions ?? this.permissions,
    );
  }

  User copyFrom(User user) {
    return copyWith(
      uuid: user.uuid,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      token: user.token,
      appAccountUrl: user.appAccountUrl,
      client: user.client,
      voip: user.voip,
      settings: settings.copyFrom(user.settings),
      permissions: user.permissions,
    );
  }

  @override
  List<Object?> get props => [
        uuid,
        email,
        firstName,
        lastName,
        token,
        appAccountUrl,
        client,
        voip,
        settings,
        permissions,
      ];

  static User fromJson(dynamic json) =>
      _$UserFromJson(json as Map<String, dynamic>);

  static Map<String, dynamic> toJson(User value) => _$UserToJson(value);
}
