import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/conditional_capitalization.dart';
import '../../settings/widgets/buttons/settings_button.dart';
import '../../settings/widgets/tile/widget.dart';
import 'cubit.dart';
import 'page.dart';

class TemporaryRedirectSettingTile extends StatelessWidget {
  const TemporaryRedirectSettingTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TemporaryRedirectCubit, TemporaryRedirectState>(
      builder: (context, state) {
        final cubit = context.read<TemporaryRedirectCubit>();
        final hasTemporaryRedirect = state is Active;

        return SettingTile(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              if (hasTemporaryRedirect) ...[
                SettingsButton(
                  onPressed: cubit.stopTemporaryRedirect,
                  text: context
                      .msg.main.temporaryRedirect.actions.stopRedirect.label
                      .toUpperCaseIfAndroid(context),
                ),
                const SizedBox(height: 8),
                Text(
                  context.msg.main.temporaryRedirect.actions.stopRedirect
                      .description,
                ),
                const SizedBox(height: 16),
              ],
              SettingsButton(
                onPressed: () => unawaited(
                  Navigator.push(
                    context,
                    TemporaryRedirectPickerPage.route(),
                  ),
                ),
                text: (hasTemporaryRedirect
                        ? context.msg.main.temporaryRedirect.actions
                            .changeRedirect.label
                        : context.msg.main.temporaryRedirect.actions
                            .setupRedirect.label)
                    .toUpperCaseIfAndroid(context),
              ),
              const SizedBox(height: 8),
              Text(
                hasTemporaryRedirect
                    ? context.msg.main.temporaryRedirect.actions.changeRedirect
                        .description
                    : context.msg.main.temporaryRedirect.actions.setupRedirect
                        .description,
                style: TextStyle(
                  color: context.brand.theme.colors.grey4,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
