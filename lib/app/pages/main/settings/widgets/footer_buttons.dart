import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../domain/user/launch_privacy_policy.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../routes.dart';
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _FooterButton(
          text: context.msg.main.settings.buttons.sendFeedback,
          icon: FontAwesomeIcons.messages,
          onPressed: () => _goToFeedbackPage(context),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _FooterButton(
                text: context.msg.main.settings.privacyPolicy,
                icon: FontAwesomeIcons.bookCircleArrowRight,
                onPressed: () => LaunchPrivacyPolicy()(),
                solid: false,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _FooterButton(
                text: context.msg.main.settings.buttons.logout,
                icon: FontAwesomeIcons.rightFromBracket,
                onPressed: () => context.read<SettingsCubit>().logout(),
                solid: false,
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _FooterButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool solid;

  const _FooterButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.solid = true,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = solid ? Colors.white : context.brand.theme.colors.primary;
    final backgroundColor =
        solid ? context.brand.theme.colors.primary : Colors.transparent;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            icon,
            color: textColor,
            size: 16,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              style: TextStyle(
                color: solid ? Colors.white : textColor,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
