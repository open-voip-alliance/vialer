import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../resources/localizations.dart';
import '../cubit.dart';
import '../widgets/tile/category/account_info.dart';
import '../widgets/tile/mobile_number.dart';
import '../widgets/tile/outgoing_number.dart';
import '../widgets/tile/username.dart';
import 'widget.dart';

class UserSubPage extends StatelessWidget {
  const UserSubPage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SettingsSubPage(
          cubit: context.watch<SettingsCubit>(),
          title: Text(
            context.msg.main.settings.subPage.user.title(state.user.fullName),
          ),
          children: (state) {
            return [
              AccountInfoCategory(
                children: [
                  MobileNumberTile(state.user),
                  OutgoingNumberTile(state.user),
                  UsernameTile(state.user),
                ],
              ),
            ];
          },
        );
      },
    );
  }
}
