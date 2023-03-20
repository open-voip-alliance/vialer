import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../domain/user/launch_privacy_policy.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../routes.dart';
import '../../../../widgets/stylized_button.dart';
import '../../util/stylized_snack_bar.dart';
import '../cubit.dart';

class FooterButtons extends StatelessWidget {
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _FooterButton(
          text: context.msg.main.settings.buttons.sendFeedback,
          icon: FontAwesomeIcons.messages,
          onPressed: () => _goToFeedbackPage(context),
        ),
        _FooterButton(
          text: context.msg.main.settings.privacyPolicy,
          icon: FontAwesomeIcons.bookCircleArrowRight,
          onPressed: () => LaunchPrivacyPolicy()(),
        ),
        _FooterButton(
          text: context.msg.main.settings.buttons.logout,
          icon: FontAwesomeIcons.rightFromBracket,
          onPressed: () => context.read<SettingsCubit>().logout(),
        ),
      ],
    );
  }
}

class _FooterButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _FooterButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          tooltip: text,
          icon: FaIcon(
            icon,
            color: context.brand.theme.colors.grey4,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: context.brand.theme.colors.grey6,
          ),
        ),
      ],
    );
  }
}
