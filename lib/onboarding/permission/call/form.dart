import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer_lite/onboarding/widgets/stylized_button.dart';
import 'package:vialer_lite/resources/theme.dart';

import 'bloc.dart';

class CallPermissionForm extends StatefulWidget {
  final VoidCallback forward;

  CallPermissionForm._(this.forward);

  static Widget create({@required VoidCallback forward}) {
    return BlocProvider<CallPermissionBloc>(
      create: (context) => CallPermissionBloc(),
      child: CallPermissionForm._(forward),
    );
  }

  @override
  State<StatefulWidget> createState() => _CallPermissionFormState();
}

class _CallPermissionFormState extends State<CallPermissionForm> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<CallPermissionBloc, CallPermissionState>(
      listener: (context, state) {
        if (state is Granted) {
          widget.forward();
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 48,
        ).copyWith(
          bottom: 24,
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: 64),
            Icon(VialerSans.phone, size: 54),
            SizedBox(height: 24),
            Text(
              'Call permission',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'This permissions is required to make calls seamlessly from'
              'the app using the default call app.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: StylizedOutlineButton(
                        text: 'Deny',
                        onPressed: () {},
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: StylizedRaisedButton(
                        text: 'Allow',
                        onPressed: () {
                          context.bloc<CallPermissionBloc>().add(Request());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
