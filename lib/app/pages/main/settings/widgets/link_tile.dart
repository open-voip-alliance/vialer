import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../cubit.dart';
import '../sub_page.dart';
import 'tile.dart';

class SettingLinkTile extends StatelessWidget {
  final Widget title;
  final Widget? description;

  final VoidCallback? onTap;

  final bool center;

  /// See [SettingTile.bordered] for more information.
  final bool? bordered;

  const SettingLinkTile({
    Key? key,
    required this.title,
    this.description,
    this.onTap,
    this.center = false,
    this.bordered,
  }) : super(key: key);

  static Widget troubleshooting() {
    return Builder(
      builder: (context) {
        return SettingLinkTile(
          title: Text(
            context
                .msg.main.settings.list.advancedSettings.troubleshooting.title,
          ),
          description: Text(
            context.msg.main.settings.list.advancedSettings.troubleshooting
                .description,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) {
                return SettingsSubPage.troubleshooting(
                  cubit: context.read<SettingsCubit>(),
                );
              }),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: SettingTile(
        label: title,
        description: description,
        center: center,
        bordered: bordered,
        child: Icon(
          VialerSans.caretRight,
          color: context.brand.theme.colors.grey4,
        ),
      ),
    );
  }
}
