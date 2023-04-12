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
  final String preposition;
  final String lastName;

  String get fullName => [firstName, preposition, lastName]
      .where((part) => part.isNotBlank)
      .join(' ');

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

  // A user must have voip config to be able to call, if they don't then this
  // suggests that there is no app account configured.
  bool get isAllowedVoipCalling =>
      voip != null && voip.sipUserId.isNotNullOrBlank;

  const User({
    required this.uuid,
    required this.email,
    required this.firstName,
    this.preposition = '',
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
    String? preposition,
    String? lastName,
    String? token,
    Uri? appAccountUrl,
    Client? client,
    UserVoipConfig? voip,
    Settings? settings,
    UserPermissions? permissions,
    // If set to true, will allow the passing of a null voip config which will
    // replace the existing one. Otherwise a null config would be ignored.
    bool allowNullVoipConfig = false,
  }) {
    return User(
      uuid: uuid ?? this.uuid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      preposition: preposition ?? this.preposition,
      lastName: lastName ?? this.lastName,
      token: token ?? this.token,
      appAccountUrl: appAccountUrl ?? this.appAccountUrl,
      client: client ?? this.client,
      voip: allowNullVoipConfig ? voip : (voip ?? this.voip),
      settings: settings ?? this.settings,
      permissions: permissions ?? this.permissions,
    );
  }

  User copyFrom(User user) {
    return copyWith(
      uuid: user.uuid,
      email: user.email,
      firstName: user.firstName,
      preposition: user.preposition,
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
        preposition,
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
