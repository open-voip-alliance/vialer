import 'package:freezed_annotation/freezed_annotation.dart';

import 'temporary_redirect.dart';

part 'temporary_redirect_did_change_event.freezed.dart';

@freezed
class TemporaryRedirectDidChangeEvent with _$TemporaryRedirectDidChangeEvent {
  factory TemporaryRedirectDidChangeEvent({
    TemporaryRedirect? current,
  }) = _TemporaryRedirectDidChangeEvent;
}
