import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/user/settings/call_setting.dart';
import '../../../resources/localizations.dart';
import '../business_availability/temporary_redirect/cubit.dart';
import '../business_availability/temporary_redirect/state.dart';
import '../widgets/temporary_redirect_picker/widget.dart';
import 'cubit.dart';
import 'widgets/tile.dart';
import 'widgets/tile_category.dart';

typedef MultiChildStateBuilder = List<Widget> Function(SettingsState state);

class SettingsSubPage extends StatelessWidget {
  final SettingsCubit cubit;
  final Widget title;
  final MultiChildStateBuilder children;

  const SettingsSubPage({
    Key? key,
    required this.cubit,
    required this.title,
    required this.children,
  }) : super(key: key);

  static Widget temporaryRedirect({
    required SettingsCubit cubit,
    required TemporaryRedirectCubit temporaryRedirectCubit,
  }) {
    return BlocProvider.value(
      value: temporaryRedirectCubit,
      child: BlocBuilder<TemporaryRedirectCubit, TemporaryRedirectState>(
        builder: (context, temporaryRedirectState) {
          final tempRedirectCubit = context.watch<TemporaryRedirectCubit>();

          return SettingsSubPage(
            cubit: cubit,
            title: Text(context.msg.main.settings.list.temporaryRedirect.title),
            children: (state) {
              return [
                TemporaryRedirectPicker(
                  initialTemporaryRedirect: temporaryRedirectState is Active
                      ? temporaryRedirectState.redirect
                      : null,
                  onStart: (destination) => tempRedirectCubit
                      .startOrUpdateCurrentTemporaryRedirect(destination)
                      .then((_) => Navigator.pop(context)),
                  onCancel: temporaryRedirectState is Active
                      ? tempRedirectCubit.stopTemporaryRedirect
                      : null,
                ),
              ];
            },
          );
        },
      ),
    );
  }

  static Widget troubleshooting({required SettingsCubit cubit}) {
    return Builder(
      builder: (context) {
        return SettingsSubPage(
          cubit: cubit,
          title: Text(
            context
                .msg.main.settings.list.advancedSettings.troubleshooting.title,
          ),
          children: (state) {
            return [
              SettingTileCategory.troubleshootingAudio(
                children: [
                  if (state.user.settings.get(CallSetting.useVoip) == true)
                    SettingTile.echoCancellationCalibration(),
                ],
              ),
            ];
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        centerTitle: true,
      ),
      body: BlocProvider.value(
        value: cubit,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.only(top: 8),
              children: children(state),
            );
          },
        ),
      ),
    );
  }
}
