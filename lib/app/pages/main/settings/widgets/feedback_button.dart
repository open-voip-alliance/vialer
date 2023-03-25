import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/app/pages/main/settings/widgets/settings_button.dart';

import '../../../../resources/localizations.dart';
import '../../../../routes.dart';
import '../../util/stylized_snack_bar.dart';
import '../cubit.dart';

class FeedbackButton extends StatelessWidget {
  Future<void> _goToFeedbackPage(BuildContext context) async {
    final sent = await Navigator.pushNamed(
      context,
      Routes.feedback,
    ) as bool? ??
        false;

    if (sent) {
      showSnackBar(
        context,
        icon: const FaIcon(FontAwesomeIcons.check),
        label: Text(context.msg.main.settings.feedback.snackBar),
      );
    }

    context.read<SettingsCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsButton(
      text: context.msg.main.settings.buttons.sendFeedback,
      icon: FontAwesomeIcons.messages,
      onPressed: () => _goToFeedbackPage(context),
    );
  }
}


