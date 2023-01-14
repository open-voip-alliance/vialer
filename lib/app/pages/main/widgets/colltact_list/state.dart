import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../../app/util/pigeon.dart';
import '../../../../../data/models/colltact.dart';

part 'state.freezed.dart';

@freezed
class ColltactsState with _$ColltactsState {
  const factory ColltactsState.loading() = LoadingColltacts;
  const factory ColltactsState.noPermission({required bool dontAskAgain}) =
      NoPermission;
  const factory ColltactsState.loaded(
    Iterable<Colltact> colltacts,
    ContactSort? contactSort,
  ) = ColltactsLoaded;
}
