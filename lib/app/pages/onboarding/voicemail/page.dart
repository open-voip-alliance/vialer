import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../cubit.dart';
import '../info/page.dart';

class VoicemailPage extends StatelessWidget {
  const VoicemailPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoPage(
      icon: const Icon(VialerSans.voicemail),
      title: Text(context.msg.onboarding.voicemail.title),
      description: Text(context.msg.onboarding.voicemail.description),
      onPressed: context.watch<OnboardingCubit>().forward,
    );
  }
}
