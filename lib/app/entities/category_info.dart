import 'package:flutter/widgets.dart';

import 'category.dart';
import 'ordered_info.dart';
import 'setting_route.dart';

class CategoryInfo extends OrderedInfo<Category> {
  @override
  final Category item;

  /// The route this category is on. Defaults to [SettingRoute.main].
  final SettingRoute route;
  @override
  final int order;
  final IconData icon;
  final String title;

  CategoryInfo({
    @required this.item,
    this.route = SettingRoute.main,
    @required this.order,
    @required this.icon,
    @required this.title,
  });
}
