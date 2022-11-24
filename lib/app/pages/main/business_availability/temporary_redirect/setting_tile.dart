import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../resources/localizations.dart';
import '../../../../util/conditional_capitalization.dart';
import '../../../../widgets/stylized_button.dart';
import '../../settings/widgets/tile.dart';
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
                StylizedButton.raised(
                  onPressed: cubit.stopTemporaryRedirect,
                  colored: true,
                  margin: EdgeInsets.zero,
                  child: Text(
                    context
                        .msg.main.temporaryRedirect.actions.stopRedirect.label
                        .toUpperCaseIfAndroid(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.msg.main.temporaryRedirect.actions.stopRedirect
                      .description,
                ),
                const SizedBox(height: 16),
              ],
              StylizedButton(
                type: hasTemporaryRedirect
                    ? StylizedButtonType.outline
                    : StylizedButtonType.raised,
                onPressed: () => Navigator.push(
                  context,
                  TemporaryRedirectPickerPage.route(),
                ),
                colored: true,
                margin: EdgeInsets.zero,
                child: Text(
                  (hasTemporaryRedirect
                          ? context.msg.main.temporaryRedirect.actions
                              .changeRedirect.label
                          : context.msg.main.temporaryRedirect.actions
                              .setupRedirect.label)
                      .toUpperCaseIfAndroid(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasTemporaryRedirect
                    ? context.msg.main.temporaryRedirect.actions.changeRedirect
                        .description
                    : context.msg.main.temporaryRedirect.actions.setupRedirect
                        .description,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
