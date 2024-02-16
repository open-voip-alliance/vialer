import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../data/models/user/brand.dart';

part 'state.freezed.dart';

@freezed
class BrandProviderState with _$BrandProviderState {
  const factory BrandProviderState(Brand brand) = _BrandProviderState;
}
