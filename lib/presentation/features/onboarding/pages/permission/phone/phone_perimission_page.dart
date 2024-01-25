import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../../data/models/user/permissions/permission.dart';
import '../../../../../resources/localizations.dart';
import '../../../../../shared/widgets/caller.dart';
import '../abstract/permission_page.dart';

class PhonePermissionPage extends StatelessWidget {
  const PhonePermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PermissionPage(
      permission: Permission.phone,
      icon: const FaIcon(FontAwesomeIcons.phone),
      title: context.msg.onboarding.permission.phone.title,
      description: Text(
        context.msg.onboarding.permission.phone
            .description(context.brand.appName),
      ),
      onPermissionGranted: context.watch<CallerCubit>().notifyCanCall,
    );
  }
}
