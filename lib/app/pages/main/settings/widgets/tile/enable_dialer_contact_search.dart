import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../../../domain/user/settings/app_setting.dart';
import '../../../../../../domain/user/user.dart';
import '../../../../../resources/localizations.dart';
import 'value.dart';
import 'widget.dart';

class EnableT9ContactSearch extends StatelessWidget {
  const EnableT9ContactSearch(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      label: Text(
        context.msg.main.settings.list.calling.enableT9ContactSearch.title,
      ),
      child: BoolSettingValue(
        user.settings,
        AppSetting.enableT9ContactSearch,
      ),
    );
  }
}
