import 'package:flutter/widgets.dart';

import '../../../../../../domain/user/user.dart';
import '../../../../../resources/localizations.dart';
import 'value.dart';
import 'widget.dart';

class UsernameTile extends StatelessWidget {
  final User user;

  const UsernameTile(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      childFillWidth: true,
      description: Text(
        context.msg.main.settings.list.accountInfo.username.description,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 10),
        child: StringValue(user.email),
      ),
    );
  }
}
