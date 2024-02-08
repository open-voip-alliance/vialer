import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../settings/widgets/settings_button.dart';
import '../../../settings/widgets/tile/widget.dart';
import '../../controllers/temporary_redirect/cubit.dart';
import '../../pages/temporary_redirect/page.dart';

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
                      .msg.main.temporaryRedirect.actions.stopRedirect.label,
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
                text: hasTemporaryRedirect
                    ? context
                        .msg.main.temporaryRedirect.actions.changeRedirect.label
                    : context
                        .msg.main.temporaryRedirect.actions.setupRedirect.label,
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
