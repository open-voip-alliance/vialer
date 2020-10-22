import 'package:flutter/widgets.dart';

import '../resources/theme.dart';
import '../resources/localizations.dart';

enum Category {
  debug,
  accountInfo,
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
      case Category.accountInfo:
        return CategoryInfo(
          order: 0,
          icon: VialerSans.user,
          title: context.msg.main.settings.list.info.title,
        );
      case Category.debug:
        return CategoryInfo(
          order: 1,
          icon: VialerSans.bug,
          title: context.msg.main.settings.list.debug.title,
        );
      default:
        throw UnsupportedError('Vialer error: Unknown category');
    }
  }
}
