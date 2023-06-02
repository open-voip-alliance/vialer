import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../resources/localizations.dart';
import '../../../../../routes.dart';
import '../../../../../util/conditional_capitalization.dart';
import '../../../util/stylized_snack_bar.dart';
import '../../cubit.dart';
import 'settings_button.dart';

class FeedbackButton extends StatefulWidget {
  const FeedbackButton({super.key});

  @override
  State<FeedbackButton> createState() => _FeedbackButtonState();
}

class _FeedbackButtonState extends State<FeedbackButton> {
  Future<void> _goToFeedbackPage() async {
    final sent = await Navigator.of(context, rootNavigator: true).pushNamed(
          Routes.feedback,
        ) as bool? ??
        false;

    if (sent) {
      if (!mounted) return;

      showSnackBar(
        context,
        icon: const FaIcon(FontAwesomeIcons.check),
        label: Text(context.msg.main.settings.feedback.snackBar),
      );
    }

    if (!mounted) return;

    context.read<SettingsCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SettingsButton(
        text: context.msg.main.settings.buttons.sendFeedbackButton
            .toUpperCaseIfAndroid(context),
        icon: FontAwesomeIcons.messages,
        onPressed: _goToFeedbackPage,
      ),
    );
  }
}
