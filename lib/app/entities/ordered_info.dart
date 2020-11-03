import 'package:meta/meta.dart';

abstract class OrderedInfo<T> {
  /// The actual item (setting, page).
  final T item;
  final int order;

  const OrderedInfo({
    @required this.item,
    @required this.order,
  });
}
