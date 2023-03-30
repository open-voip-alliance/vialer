import 'package:freezed_annotation/freezed_annotation.dart';

import '../user.dart';

part 'logged_in_user_was_refreshed.freezed.dart';

@freezed
class LoggedInUserWasRefreshed with _$LoggedInUserWasRefreshed {
  const factory LoggedInUserWasRefreshed(User user) = _LoggedInUserWasRefreshed;
}
