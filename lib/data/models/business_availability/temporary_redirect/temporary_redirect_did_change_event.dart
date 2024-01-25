import 'package:freezed_annotation/freezed_annotation.dart';

import '../../event/event_bus.dart';
import 'temporary_redirect.dart';

part 'temporary_redirect_did_change_event.freezed.dart';

@freezed
class TemporaryRedirectDidChangeEvent
    with _$TemporaryRedirectDidChangeEvent
    implements EventBusEvent {
  factory TemporaryRedirectDidChangeEvent({
    TemporaryRedirect? current,
  }) = _TemporaryRedirectDidChangeEvent;
}
