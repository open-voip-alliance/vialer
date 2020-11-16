import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../entities/setting_route_info.dart';
import 'cubit.dart';
import 'widgets/settings_list_view.dart';

class SettingsSubPage extends StatelessWidget {
  final SettingsCubit cubit;
  final SettingRouteInfo routeInfo;

  const SettingsSubPage({
    Key key,
    @required this.cubit,
    @required this.routeInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(routeInfo.title),
        centerTitle: true,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        cubit: cubit,
        builder: (context, state) {
          return SettingsListView(
            route: routeInfo.item,
            settings: state.settings,
            allowedCategories: state.allowedCategories,
            onSettingChanged: cubit.changeSetting,
          );
        },
      ),
    );
  }
}
