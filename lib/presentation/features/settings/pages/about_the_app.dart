import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:vialer/data/models/user/brand.dart';
import 'package:vialer/presentation/features/settings/widgets/support_button.dart';
import 'package:vialer/presentation/features/settings/widgets/tile/feature_announcement.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/util/brand.dart';

import '../controllers/cubit.dart';
import '../widgets/tile/build_info.dart';
import '../widgets/tile/privacy_policy.dart';
import 'settings_subpage.dart';

class AboutTheAppSubPage extends StatelessWidget {
  const AboutTheAppSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final cubit = context.watch<SettingsCubit>();

        return SettingsSubPage(
          cubit: cubit,
          title: context.msg.main.settings.subPage.aboutTheApp.title,
          child: (state) {
            return Column(
              children: [
                ListView(
                  shrinkWrap: true,
                  children: [
                    FeatureAnnouncementTile(
                      hasUnreadFeatureAnnouncements:
                          state.hasUnreadFeatureAnnouncements,
                    ),
                    const PrivacyPolicyTile(),
                    if (state.buildInfo != null)
                      BuildInfoTile(state.buildInfo!),
                  ],
                ),
                if (context.brand.hasSupportUrl) ...[
                  Gap(26),
                  SupportButton(),
                ],
              ],
            );
          },
        );
      },
    );
  }
}
