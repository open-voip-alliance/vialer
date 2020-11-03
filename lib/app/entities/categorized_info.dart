import 'package:meta/meta.dart';

import 'ordered_info.dart';
import 'category.dart';

abstract class CategorizedInfo<T> extends OrderedInfo<T> {
  @override
  final T item;

  /// The order is relative to the category it's in.
  @override
  final int order;
  final Category category;

  const CategorizedInfo({
    @required this.item,
    @required this.order,
    @required this.category,
  });
}
