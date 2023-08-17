import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../domain/user/user.dart';

part 'state.freezed.dart';

@freezed
class WelcomeState with _$WelcomeState {
  const factory WelcomeState({User? user}) = _WelcomeState;
}
