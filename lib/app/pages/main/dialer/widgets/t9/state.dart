import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../../data/models/colltact.dart';
import '../../../../../../domain/colltacts/t9_colltact.dart';

part 'state.freezed.dart';

@freezed
class T9ColltactsState with _$T9ColltactsState {
  const factory T9ColltactsState.loading() = LoadingColltacts;
  const factory T9ColltactsState.loaded(
    List<Colltact> colltacts,
    List<T9Colltact> filteredColltacts,
  ) = ColltactsLoaded;
  const factory T9ColltactsState.noPermission({required bool dontAskAgain}) =
      NoPermission;
}
