import 'package:freezed_annotation/freezed_annotation.dart';

import '../../event/event_bus.dart';
import '../colleagues/colleague.dart';

part 'colleague_list_did_change.freezed.dart';

@freezed
class ColleagueListDidChangeEvent
    with _$ColleagueListDidChangeEvent
    implements EventBusEvent {
  const factory ColleagueListDidChangeEvent(
    List<Colleague> colleagues,
  ) = _ColleagueListDidChangeEvent;
}
