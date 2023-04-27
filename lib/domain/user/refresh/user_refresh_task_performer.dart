// ignore_for_file: avoid_types_on_closure_parameters

import 'package:meta/meta.dart';

import '../client.dart';
import '../permissions/user_permissions.dart';
import '../settings/settings.dart';
import '../user.dart';

typedef UserMutator = User Function(User);
typedef ClientMutator = Client Function(Client);
typedef SettingsMutator = Settings Function(Settings);

User unmutatedUser(User user) => user;

/// A [UserRefreshTaskPerformer] is a task that will "refresh" the logged-in
/// user with new data provided by the server.
abstract class UserRefreshTaskPerformer {
  const UserRefreshTaskPerformer();

  /// Perform this [UserRefreshTaskPerformer], will automatically be skipped if
  /// the User is not permitted.
  Future<UserMutator> call(User user) async {
    if (!shouldRun(user)) return unmutatedUser;

    return performUserRefreshTask(user);
  }

  /// The [UserRefreshTaskPerformer] must perform any slow actions, such as API
  /// requests, and then return a callback to update the [User] object. The
  /// former will be run in parallel for performance reasons, the latter will
  /// then be performed synchronously to ensure consistency.
  ///
  /// Any mutation of the user **must** be performed within the
  /// [UserMutator] or it will not have any effect.
  @protected
  Future<UserMutator> performUserRefreshTask(User user);

  /// Determine if the user is permitted to perform this refresh task,
  /// if no implementation is provided, it is assumed that they are permitted.
  ///
  /// This should always be implemented if the API request(s) to refresh a user
  /// are behind a permission as this will avoid unnecessary, failing, api
  /// requests.
  @protected
  bool isPermitted(UserPermissions userPermissions) => true;

  /// Determines if this refresh task should be run, if it is dependent on a
  /// [UserPermissions] check, make sure to use the [isPermitted] method. This
  /// is for any factors outside of simply checking permissions.
  ///
  /// Implementing this method will mean [isPermitted] is ignored.
  @protected
  bool shouldRun(User user) => isPermitted(user.permissions);
}

/// A task that is specifically to update the [Client] entity, while this is
/// possible just by using a [UserRefreshTaskPerformer] using this instead
/// reduces boiler-plate and reduces the chance of errors if you're trying to
/// update the [Client] entity via a [User].
///
/// If you only need to update [Client] and nothing on the [User] this should
/// be used.
///
/// This is still a [UserRefreshTask] and will behave exactly like any other,
/// these are only to make the code more readable.
abstract class ClientRefreshTaskPerformer extends UserRefreshTaskPerformer {
  const ClientRefreshTaskPerformer();

  @override
  Future<UserMutator> performUserRefreshTask(User user) async {
    final mutator = await performClientRefreshTask(user.client);
    return (User user) => user.copyWith(client: mutator(user.client));
  }

  @protected
  Future<ClientMutator> performClientRefreshTask(Client client);
}

/// See [ClientRefreshTaskPerformer] for more information, this applies in
/// exactly the same way but to [Settings] rather than [Client].
abstract class SettingsRefreshTaskPerformer extends UserRefreshTaskPerformer {
  const SettingsRefreshTaskPerformer();

  @override
  Future<UserMutator> performUserRefreshTask(User user) async {
    final mutator = await performSettingsRefreshTask(user);
    return (User user) => user.copyWith(settings: mutator(user.settings));
  }

  @protected
  Future<SettingsMutator> performSettingsRefreshTask(
    // The [User] is passed to this because it would probably be required for
    // API requests. It's highly recommended you name this parameter _ if it's
    // not necessary.
    User user,
  );
}
