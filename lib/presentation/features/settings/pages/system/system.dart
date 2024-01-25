import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/localizations.dart';

import '../../controllers/cubit.dart';
import '../../widgets/tile/link/sub_page.dart';
import '../settings_subpage.dart';
import 'feature_flags.dart';
import 'logs.dart';

class SystemSubPage extends StatelessWidget {
  const SystemSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final cubit = context.watch<SettingsCubit>();

        return SettingsSubPage(
          cubit: cubit,
          title: context.msg.main.settings.list.advancedSettings.troubleshooting
              .system.title,
          child: (state) {
            return ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                SubPageLinkTile(
                  title: context.msg.main.settings.list.advancedSettings
                      .troubleshooting.logs.title,
                  icon: FontAwesomeIcons.scroll,
                  cubit: cubit,
                  pageBuilder: (_) => const LogSubPage(),
                ),
                SubPageLinkTile(
                  title: context.msg.main.settings.list.advancedSettings
                      .troubleshooting.featureFlags.title,
                  icon: FontAwesomeIcons.flag,
                  cubit: cubit,
                  pageBuilder: (_) => const FeatureFlagsSubPage(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
