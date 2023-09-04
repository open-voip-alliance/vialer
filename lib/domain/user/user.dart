// ignore_for_file: always_put_required_named_parameters_first

import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vialer/dependency_locator.dart';
import 'package:vialer/domain/user/settings/settings_repository.dart';

import '../../app/util/nullable_copy_with_argument.dart';
import '../voipgrid/user_voip_config.dart';
import 'client.dart';
import 'permissions/user_permissions.dart';

part 'user.g.dart';
part 'user.freezed.dart';

@Freezed(copyWith: false)
class User with _$User {
  const User._();

  const factory User({
    required String uuid,
    required String email,
    required String firstName,
    @Default('') String preposition,
    required String lastName,
    String? token,
    Uri? appAccountUrl,
    String? webphoneAccountId,
    @JsonKey(toJson: Client.toJson, fromJson: Client.fromJson)
    required Client client,
    @JsonKey(
      toJson: UserVoipConfig.serializeToJson,
      fromJson: UserVoipConfig.serializeFromJson,
    )
    UserVoipConfig? voip,
    @JsonKey(
      toJson: UserPermissions.serializeToJson,
      fromJson: UserPermissions.fromJson,
    )
    @Default(UserPermissions())
    UserPermissions permissions,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  String get fullName => [firstName, preposition, lastName]
      .where((part) => part.isNotBlank)
      .join(' ');

  // A user must have voip config to be able to call, if they don't then this
  // suggests that there is no app account configured.
  bool get isAllowedVoipCalling =>
      voip != null && voip.sipUserId.isNotNullOrBlank;

  String? get appAccountId => appAccountUrl?.pathSegments.lastOrNullWhere(
        (p) => p.isNotEmpty,
      );

  bool get hasAppAccount => appAccountId != null;

  User copyWith({
    String? uuid,
    String? email,
    String? firstName,
    String? preposition,
    String? lastName,
    String? token,
    Uri? appAccountUrl,
    Client? client,
    NullableCopyWithArgument<UserVoipConfig> voip,
    UserPermissions? permissions,
    NullableCopyWithArgument<String> webphoneAccountId,
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
      voip: voip.valueOrNull(unmodified: this.voip),
      permissions: permissions ?? this.permissions,
      webphoneAccountId: webphoneAccountId.valueOrNull(
        unmodified: this.webphoneAccountId,
      ),
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
      voip: () => user.voip,
      permissions: user.permissions,
    );
  }
}

extension SettingsAccess on User {
  SettingsRepository get settings => dependencyLocator<SettingsRepository>();
}
