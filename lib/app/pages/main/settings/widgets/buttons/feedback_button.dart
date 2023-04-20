import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../resources/localizations.dart';
import '../../../../../routes.dart';
import '../../../util/stylized_snack_bar.dart';
import '../../cubit.dart';
import 'settings_button.dart';

class FeedbackButton extends StatelessWidget {
  Future<void> _goToFeedbackPage(BuildContext context) async {
    final sent = await Navigator.of(context, rootNavigator: true).pushNamed(
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SettingsButton(
        text: context.msg.main.settings.buttons.sendFeedbackButton,
        icon: FontAwesomeIcons.messages,
        onPressed: () => _goToFeedbackPage(context),
      ),
    );
  }
}
