import 'package:meta/meta.dart';

import 'category.dart';

class SettingInfo {
  final Category category;
  final String name;
  final String description;

  SettingInfo({
    @required this.category,
    @required this.name,
    this.description,
  });
}
