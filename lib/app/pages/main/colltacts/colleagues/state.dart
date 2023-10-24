import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../domain/relations/colleagues/colleague.dart';

part 'state.freezed.dart';

class ColleaguesState with _$ColleaguesState {
  const factory ColleaguesState.loading({
    required bool showOnlineColleaguesOnly,
  }) = LoadingColleagues;

  const factory ColleaguesState.loaded(
    List<Colleague> colleagues, {
    required bool showOnlineColleaguesOnly,
    @Default(true) bool upToDate,
  }) = ColleaguesLoaded;
}

extension Filtered on ColleaguesLoaded {
  List<Colleague> get filteredColleagues => showOnlineColleaguesOnly
      ? colleagues.filter((colleague) => colleague.isOnline).toList()
      : colleagues;
}
