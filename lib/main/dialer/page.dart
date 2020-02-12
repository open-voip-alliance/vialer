import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../resources/theme.dart';
import '../../widgets/transparent_status_bar.dart';
import 'bloc.dart';
import 'widgets/key_input.dart';
import 'widgets/keypad.dart';

class DialerPage extends StatefulWidget {
  DialerPage._();

  static Widget create() {
    return BlocProvider<DialerBloc>(
      create: (context) => DialerBloc(),
      child: DialerPage._(),
    );
  }

  @override
  State<StatefulWidget> createState() => _DialerPageState();
}

class _DialerPageState extends State<DialerPage> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TransparentStatusBar(
        brightness: Brightness.dark,
        child: Column(
          children: <Widget>[
            Material(
              elevation: context.isIOS ? 0 : 8,
              child: SafeArea(
                child: SizedBox(
                  height: 96,
                  child: Center(
                    child: KeyInput(
                      controller: _controller,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Keypad(
                      controller: _controller,
                      onCallButtonPressed: () {
                        context.bloc<DialerBloc>().add(Call(_controller.text));
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
