import 'package:flutter/widgets.dart';

import '../resources/theme.dart';
import '../resources/localizations.dart';

enum Category {
  debug,
}

class CategoryInfo {
  final IconData icon;
  final String title;

  CategoryInfo(this.icon, this.title);
}

extension CategoryMapper on Category {
  CategoryInfo toInfo(BuildContext context) {
    switch (this) {
      case Category.debug:
        return CategoryInfo(
          VialerSans.speaker,
          context.msg.main.settings.list.debug.title,
        );
      default:
        throw UnsupportedError('Unknown category');
    }
  }
}
