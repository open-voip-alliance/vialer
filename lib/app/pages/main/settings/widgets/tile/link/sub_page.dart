import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../resources/theme.dart';
import '../../../cubit.dart';

class SubPageLinkTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final SettingsCubit cubit;
  final WidgetBuilder pageBuilder;

  const SubPageLinkTile({
    super.key,
    required this.title,
    required this.icon,
    required this.cubit,
    required this.pageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        platformPageRoute(
          context: context,
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: pageBuilder(context),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.brand.theme.colors.grey3,
                  ),
                  child: FaIcon(
                    icon,
                    size: 16,
                    color: context.brand.theme.colors.grey6,
                  ),
                  alignment: Alignment.center,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            FaIcon(
              FontAwesomeIcons.angleRight,
              color: context.brand.theme.colors.grey4,
            ),
          ],
        ),
      ),
    );
  }
}
