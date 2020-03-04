import 'package:flutter/material.dart';

import '../../../resources/theme.dart';
import '../../../resources/localizations.dart';

import '../info/page.dart';

class VoicemailPage extends StatelessWidget {
  final VoidCallback forward;

  const VoicemailPage(this.forward, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoPage(
      icon: Icon(VialerSans.speaker),
      title: Text(context.msg.onboarding.voicemail.title),
      description: Text(context.msg.onboarding.voicemail.description),
      onPressed: forward,
    );
  }
}
