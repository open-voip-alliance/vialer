import 'package:meta/meta.dart';

import 'category.dart';

class SettingInfo {
  final int order;
  final Category category;
  final String name;
  final String description;

  SettingInfo({
    @required this.order,
    @required this.category,
    @required this.name,
    this.description,
  });
}
