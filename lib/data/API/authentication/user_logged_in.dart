import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vialer/data/models/event/event_bus.dart';
import 'package:vialer/data/models/user/user.dart';

part 'user_logged_in.freezed.dart';

@freezed
class UserLoggedIn with _$UserLoggedIn implements EventBusEvent {
  const factory UserLoggedIn({required User user}) = _UserLoggedIn;
}
