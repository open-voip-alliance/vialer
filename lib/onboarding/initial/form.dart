import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/stylized_button.dart';

class InitialForm extends StatelessWidget {
  final VoidCallback forward;

  const InitialForm({Key key, this.forward}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Provider.of<EdgeInsets>(context),
      child: Column(
        children: <Widget>[
          Text(
            'Private\nbusiness calls',
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
            'Private calling with your business'
                '\nnumber just got an upgrade',
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
                SizedBox(
                  width: double.infinity,
                  child: StylizedRaisedButton(
                    text: 'Create account',
                    onPressed: () {},
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: StylizedOutlineButton(
                    text: 'Sign in with Vialer Lite account',
                    onPressed: () => forward(),
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
