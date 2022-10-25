import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect.dart';

part 'state.freezed.dart';

@freezed
class TemporaryRedirectState with _$TemporaryRedirectState {
  const factory TemporaryRedirectState.none() = None;
  const factory TemporaryRedirectState.active(TemporaryRedirect redirect) =
      Active;
}
