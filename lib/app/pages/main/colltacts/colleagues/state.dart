import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../domain/user_availability/colleagues/colleague.dart';

part 'state.freezed.dart';

@freezed
class ColleagueState with _$ColleagueState {
  const factory ColleagueState.loading({
    required bool showOnlineColleaguesOnly,
  }) = LoadingColleagues;
  const factory ColleagueState.unreachable({
    required bool showOnlineColleaguesOnly,
  }) = WebSocketUnreachable;
  const factory ColleagueState.loaded(
    List<Colleague> colleagues, {
    required bool showOnlineColleaguesOnly,
  }) = ColleaguesLoaded;
}

extension Filtered on ColleaguesLoaded {
  List<Colleague> get filteredColleagues => showOnlineColleaguesOnly
      ? colleagues.filter((colleague) => colleague.isOnline).toList()
      : colleagues;
}
