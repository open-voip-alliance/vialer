import 'package:dartx/dartx.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'client.dart';
import 'settings/settings.dart';
import 'user_permissions.dart';

part 'user.g.dart';

@immutable
@JsonSerializable()
class User extends Equatable {
  final String uuid;

  final String email;

  final String firstName;
  final String lastName;

  final String? token;

  final Uri? appAccountUrl;

  String? get appAccountId => appAccountUrl?.pathSegments.lastOrNullWhere(
        (p) => p.isNotEmpty,
      );

  @JsonKey(defaultValue: null, toJson: Client.toJson, fromJson: Client.fromJson)
  final Client? client;

  bool get canChangeOutgoingNumber => client?.uuid != null;

  @JsonKey(toJson: Settings.toJson, fromJson: Settings.fromJson)
  final Settings settings;

  @JsonKey(toJson: UserPermissions.toJson, fromJson: UserPermissions.fromJson)
  final UserPermissions permissions;

  const User({
    required this.uuid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.token,
    this.appAccountUrl,
    this.client,
    required this.settings,
    this.permissions = const UserPermissions.defaults(),
  });

  User copyWith({
    String? uuid,
    String? email,
    String? firstName,
    String? lastName,
    String? token,
    Uri? appAccountUrl,
    Client? client,
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
        settings,
        permissions,
      ];

  static User fromJson(dynamic json) =>
      _$UserFromJson(json as Map<String, dynamic>);

  static Map<String, dynamic> toJson(User value) => _$UserToJson(value);
}
