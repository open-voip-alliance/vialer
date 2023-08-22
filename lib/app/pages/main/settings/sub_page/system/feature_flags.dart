import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recase/recase.dart';
import 'package:vialer/domain/feature/has_feature.dart';

import '../../../../../../domain/feature/feature.dart';
import '../../cubit.dart';
import '../widget.dart';
import '../../../../../resources/localizations.dart';
import 'logs.dart';

class FeatureFlagsSubPage extends StatelessWidget {
  const FeatureFlagsSubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final featureFlags = Feature.values;

    return SettingsSubPage(
      cubit: context.watch<SettingsCubit>(),
      title: context.msg.main.settings.list.advancedSettings.troubleshooting
          .featureFlags.title,
      child: (state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: BasicDividedListView(
            itemBuilder: (_, index) {
              return _FeatureFlagItem(feature: featureFlags[index]);
            },
            itemCount: featureFlags.length,
            fallback: (_) {
              return Text(
                context.msg.main.settings.list.advancedSettings.troubleshooting
                    .featureFlags.none,
              );
            },
          ),
        );
      },
    );
  }
}

class _FeatureFlagItem extends StatelessWidget {
  const _FeatureFlagItem({required this.feature});

  final Feature feature;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(ReCase(feature.name).sentenceCase),
      trailing: hasFeature(feature)
          ? FaIcon(
              FontAwesomeIcons.solidCircleCheck,
              color: Colors.green,
            )
          : FaIcon(
              FontAwesomeIcons.solidCircleXmark,
              color: Colors.red,
            ),
    );
  }
}
