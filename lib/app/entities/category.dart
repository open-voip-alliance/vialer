import 'package:flutter/widgets.dart';

import '../resources/theme.dart';
import '../resources/localizations.dart';

enum Category {
  debug,
  info,
}

class CategoryInfo {
  final IconData icon;
  final String title;
  final int order;

  CategoryInfo({
    @required this.icon,
    @required this.title,
    @required this.order,
  });
}

extension CategoryMapper on Category {
  CategoryInfo toInfo(BuildContext context) {
    switch (this) {
      case Category.debug:
        return CategoryInfo(
          icon: VialerSans.bug,
          title: context.msg.main.settings.list.debug.title,
          order: 1,
        );
      case Category.info:
        return CategoryInfo(
          icon: VialerSans.user,
          title: context.msg.main.settings.list.info.title,
          order: 0,
        );
      default:
        throw UnsupportedError('Vialer error, unknown category');
    }
  }
}
