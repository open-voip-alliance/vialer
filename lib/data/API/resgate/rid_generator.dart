import '../../../domain/usecases/user/get_logged_in_user.dart';
import '../../models/user/user.dart';

mixin RidGenerator {
  late User _user = GetLoggedInUserUseCase()();

  /// A helper function to easily retrieve the user and client uuids to form
  /// rids.
  String createRid(
    String Function(String userUuid, String clientUuid) callback,
  ) =>
      callback(_user.uuid, _user.client.uuid);

  RegExp createRidRegex(
    RegExp Function(String userUuid, String clientUuid) callback,
  ) =>
      callback(_user.uuid, _user.client.uuid);
}
