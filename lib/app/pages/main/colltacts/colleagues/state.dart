import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../domain/user_availability/colleagues/colleague.dart';

part 'state.freezed.dart';

@freezed
class ColleagueState with _$ColleagueState {
  //wip Change to ColleaguesLoaded + LoadingColleagues to be consistent with ContactState?
  const factory ColleagueState.loading() = Loading;
  const factory ColleagueState.unreachable() = WebSocketUnreachable;
  const factory ColleagueState.loaded(List<Colleague> colleagues) = Loaded;
}
