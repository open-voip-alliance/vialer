import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../resources/theme.dart';
import '../../../resources/localizations.dart';

import '../../../widgets/transparent_status_bar.dart';
import 'widgets/key_input.dart';
import 'widgets/keypad.dart';
import '../widgets/conditional_placeholder.dart';
import '../../../widgets/stylized_button.dart';
import '../widgets/caller.dart' hide CanCall;

import '../../../../domain/entities/brand.dart';

import '../../../util/conditional_capitalization.dart';

import 'cubit.dart';

class DialerPage extends StatefulWidget {
  @override
  _DialerPageState createState() => _DialerPageState();
}

class _DialerPageState extends State<DialerPage> {
  final _keypadController = TextEditingController();

  void _onStateChanged(BuildContext context, DialerState state) {
    if (state is CanCall &&
        state.lastCalledDestination != null &&
        _keypadController.text.isEmpty) {
      _keypadController.text = state.lastCalledDestination;
    }

    if (state is CallInitiated) {
      Future.delayed(Duration(milliseconds: 200), () {
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TransparentStatusBar(
        brightness: Brightness.dark,
        child: BlocProvider<DialerCubit>(
          create: (_) => DialerCubit(context.bloc<CallerCubit>()),
          child: BlocConsumer<DialerCubit, DialerState>(
            listener: _onStateChanged,
            builder: (context, state) {
              final cubit = context.bloc<DialerCubit>();
              final appName = Provider.of<Brand>(context).appName;

              return ConditionalPlaceholder(
                showPlaceholder: state is! CanCall,
                placeholder: Warning(
                  title: Text(context.msg.main.dialer.noPermission.title),
                  description: state is NoPermission && !state.dontAskAgain
                      ? Text(
                          context.msg.main.dialer.noPermission
                              .description(appName),
                        )
                      : Text(
                          context.msg.main.dialer.noPermission
                              .permanentDescription(appName),
                        ),
                  icon: Icon(VialerSans.missedCall),
                  children: state is NoPermission && !state.dontAskAgain
                      ? <Widget>[
                          SizedBox(height: 40),
                          StylizedButton.raised(
                            colored: true,
                            onPressed: cubit.requestPermission,
                            child: Text(
                              context.msg.main.dialer.noPermission.button
                                  .toUpperCaseIfAndroid(context),
                            ),
                          ),
                        ]
                      : <Widget>[],
                ),
                child: Column(
                  children: <Widget>[
                    Material(
                      elevation: context.isIOS ? 0 : 8,
                      child: SafeArea(
                        child: SizedBox(
                          height: 96,
                          child: Center(
                            child: KeyInput(
                              controller: _keypadController,
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
                            controller: _keypadController,
                            onCallButtonPressed: () =>
                                cubit.startCall(_keypadController.text),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
