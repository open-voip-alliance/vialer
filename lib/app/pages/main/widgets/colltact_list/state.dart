import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../../app/util/pigeon.dart';
import '../../../../../data/models/colltact.dart';

part 'state.freezed.dart';

@freezed
class ColltactsState with _$ColltactsState {
  const factory ColltactsState.loading() = LoadingColltacts;

  const factory ColltactsState.loaded({
    required Iterable<Colltact> colltacts,
    ContactSort? contactSort,
    required bool noContactPermission,
    required bool dontAskAgain,
  }) = ColltactsLoaded;
}
