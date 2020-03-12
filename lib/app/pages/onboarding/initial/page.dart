import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/stylized_button.dart';

import '../../../resources/localizations.dart';

class InitialPage extends StatelessWidget {
  final VoidCallback forward;

  const InitialPage(this.forward, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Provider.of<EdgeInsets>(context),
      child: Column(
        children: <Widget>[
          Text(
            context.msg.onboarding.initial.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 32,
              horizontal: 96,
            ),
            child: Divider(
              color: Colors.white,
              thickness: 2,
            ),
          ),
          Text(
            context.msg.onboarding.initial.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: StylizedRaisedButton(
                    text: context.msg.onboarding.button.login,
                    onPressed: forward,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
