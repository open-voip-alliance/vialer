import 'package:flutter/material.dart';

import 'categorized_info.dart';
import 'category.dart';

import 'setting_route.dart';

class SettingRouteInfo extends CategorizedInfo<SettingRoute> {
  @override
  final SettingRoute item;

  @override
  final int order;

  /// The category of the tile that links to the route.
  @override
  final Category category;
  final String title;
  final String description;

  SettingRouteInfo({
    @required this.item,
    @required this.order,
    @required this.category,
    @required this.title,
    this.description,
  });
}
