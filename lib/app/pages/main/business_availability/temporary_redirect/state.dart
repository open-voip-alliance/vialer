import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../domain/business_availability/temporary_redirect/temporary_redirect.dart';

part 'state.freezed.dart';

@freezed
class TemporaryRedirectState with _$TemporaryRedirectState {
  const factory TemporaryRedirectState.none(
    Iterable<TemporaryRedirectDestination> availableDestinations,
  ) = None;

  const factory TemporaryRedirectState.active(
    Iterable<TemporaryRedirectDestination> availableDestinations,
    TemporaryRedirect redirect,
  ) = Active;
}
