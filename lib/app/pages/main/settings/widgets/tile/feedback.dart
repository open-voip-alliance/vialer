import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../resources/localizations.dart';
import 'category/widget.dart';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../routes.dart';
import '../../../util/stylized_snack_bar.dart';
import '../../cubit.dart';

class FeedbackTile extends StatefulWidget {
  const FeedbackTile({Key? key}) : super(key: key);

  @override
  State<FeedbackTile> createState() => _FeedbackTileState();
}

class _FeedbackTileState extends State<FeedbackTile> {
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
    return SettingLinkTileCategory(
      onTap: _goToFeedbackPage,
      text: context.msg.main.settings.buttons.sendFeedback,
      icon: FontAwesomeIcons.messages,
    );
  }
}
