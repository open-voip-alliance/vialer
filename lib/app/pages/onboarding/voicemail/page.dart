import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../resources/localizations.dart';
import '../cubit.dart';
import '../info/page.dart';

class VoicemailPage extends StatelessWidget {
  const VoicemailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoPage(
      icon: const FaIcon(FontAwesomeIcons.voicemail),
      title: Text(context.msg.onboarding.voicemail.title),
      description: Text(context.msg.onboarding.voicemail.description),
      onPressed: context.watch<OnboardingCubit>().forward,
    );
  }
}
