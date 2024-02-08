import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../../data/models/business_availability/temporary_redirect/temporary_redirect.dart';

part 'state.freezed.dart';

@freezed
class TemporaryRedirectState with _$TemporaryRedirectState {
  const factory TemporaryRedirectState.none(
    Iterable<TemporaryRedirectDestination> availableRedirectDestinations,
  ) = None;

  const factory TemporaryRedirectState.active(
    Iterable<TemporaryRedirectDestination> availableRedirectDestinations,
    TemporaryRedirect redirect,
  ) = Active;
}
