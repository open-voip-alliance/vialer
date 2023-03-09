import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../resources/theme.dart';
import '../../../cubit.dart';

class SubPageLinkTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final SettingsCubit cubit;
  final Widget child;

  const SubPageLinkTile({
    super.key,
    required this.title,
    required this.icon,
    required this.cubit,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: child,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
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
                      color: context.brand.theme.colors.grey7,
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
      ),
    );
  }
}
