import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/presentation/features/settings/widgets/tile/feature_announcement.dart';
import 'package:vialer/presentation/resources/localizations.dart';

import '../controllers/cubit.dart';
import '../widgets/tile/build_info.dart';
import '../widgets/tile/feedback.dart';
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
            return ListView(
              children: [
                FeatureAnnouncementTile(
                  hasUnreadFeatureAnnouncements:
                      state.hasUnreadFeatureAnnouncements,
                ),
                const FeedbackTile(),
                const PrivacyPolicyTile(),
                if (state.buildInfo != null) BuildInfoTile(state.buildInfo!),
              ],
            );
          },
        );
      },
    );
  }
}
