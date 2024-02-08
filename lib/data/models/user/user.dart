// ignore_for_file: always_put_required_named_parameters_first

import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vialer/data/models/user/refresh/tasks/voipgrid_user_permissions.dart';
import 'package:vialer/data/models/user/settings/settings.dart';
import 'package:vialer/data/repositories/user/settings/settings_repository.dart';
import 'package:vialer/dependency_locator.dart';

import '../../../presentation/util/nullable_copy_with_argument.dart';
import '../../repositories/voipgrid/user_permissions.dart';
import '../voipgrid/app_account.dart';
import 'client.dart';

part 'user.freezed.dart';
part 'user.g.dart';

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
    @JsonKey(toJson: Client.serializeToJson, fromJson: Client.fromJson)
    required Client client,
    @JsonKey(
      name: 'voip',
      toJson: AppAccount.serializeToJson,
      fromJson: AppAccount.serializeFromJson,
    )
    AppAccount? appAccount,
    @Default({}) Permissions permissions,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  String get fullName => [firstName, preposition, lastName]
      .where((part) => part.isNotBlank)
      .join(' ');

  // A user must have voip config to be able to call, if they don't then this
  // suggests that there is no app account configured.
  bool get isAllowedVoipCalling =>
      appAccount != null && appAccount.sipUserId.isNotNullOrBlank;

  String? get appAccountId => appAccountUrl?.pathSegments.lastOrNullWhere(
        (p) => p.isNotEmpty,
      );

  bool get hasAppAccount => appAccountId != null;

  bool hasPermission(Permission permission) => permissions.contains(permission);

  User copyWith({
    String? uuid,
    String? email,
    String? firstName,
    String? preposition,
    String? lastName,
    String? token,
    Uri? appAccountUrl,
    Client? client,
    NullableCopyWithArgument<AppAccount> appAccount,
    Settings? settings,
    Permissions? permissions,
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
      appAccount: appAccount.valueOrNull(unmodified: this.appAccount),
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
      appAccount: () => user.appAccount,
      permissions: user.permissions,
      webphoneAccountId: () => user.webphoneAccountId,
    );
  }
}

extension SettingsAccess on User {
  SettingsRepository get settings => dependencyLocator<SettingsRepository>();
}
