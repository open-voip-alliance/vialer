import 'package:meta/meta.dart';

import 'category.dart';

class SettingInfo {
  final Category category;
  final String name;
  final String description;
  final int order;

  SettingInfo({
    @required this.category,
    @required this.name,
    @required this.order,
    this.description,
  });
}
