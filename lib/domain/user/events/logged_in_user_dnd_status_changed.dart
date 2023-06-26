import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vialer/domain/calling/dnd/dnd_repository.dart';

import '../../event/event_bus.dart';

part 'logged_in_user_dnd_status_changed.freezed.dart';

@freezed
class LoggedInUserDndStatusChanged
    with _$LoggedInUserDndStatusChanged
    implements EventBusEvent {
  const factory LoggedInUserDndStatusChanged(
    DndStatus dndStatus,
  ) = _LoggedInUserDndStatusChanged;
}
