import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../../../domain/user/settings/app_setting.dart';
import '../../../../../../domain/user/user.dart';
import '../../../../../resources/localizations.dart';
import 'value.dart';
import 'widget.dart';

class EnableDialerContactSearch extends StatelessWidget {
  final User user;

  const EnableDialerContactSearch(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      label: Text(
        context.msg.main.settings.list.calling.enableDialerContactSearch.title,
      ),
      // description: Text(
      //   context.msg.main.settings.list.calling.enableDialerContactSearch.description,
      // ),
      child: BoolSettingValue(
        user.settings,
        AppSetting.enableDialerContactSearch,
      ),
    );
  }
}
