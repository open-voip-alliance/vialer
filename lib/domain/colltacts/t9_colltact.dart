import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/colltact.dart';
import '../call_records/item.dart';

part 't9_colltact.freezed.dart';

@freezed
class T9Colltact with _$T9Colltact {
  const factory T9Colltact({
    required Colltact colltact,
    required Item relevantPhoneNumber,
  }) = _T9Colltact;
}
