import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../resources/localizations.dart';
import '../../../../../resources/theme.dart';
import '../../../../../util/brand.dart';
import '../../../../../util/conditional_capitalization.dart';
import '../../../../../widgets/stylized_button.dart';
import '../../../../../widgets/transparent_status_bar.dart';
import '../../../call/widgets/call_button.dart';
import '../../../widgets/caller/cubit.dart';
import '../../../widgets/conditional_placeholder.dart';
import '../../../widgets/dial_pad/keypad.dart';
import '../../../widgets/dial_pad/widget.dart';
import '../../cubit.dart';
import '../t9/widget.dart';

class Dialer extends StatefulWidget {
  final Function(String) onCall;
  final IconData? callButtonIcon;

  Dialer({required this.onCall, this.callButtonIcon,});

  @override
  _DialerState createState() => _DialerState();
}

class _DialerState extends State<Dialer> {
  final _dialPadController = TextEditingController();

  void _onDialerStateChanged(BuildContext context, DialerState state) {
    if (state.lastCalledDestination != null &&
        _dialPadController.text.isEmpty) {
      _dialPadController.text = state.lastCalledDestination!;
    }
  }

  void _call(BuildContext context) {
    final number = _dialPadController.text;

    widget.onCall(number);

    _dialPadController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return TransparentStatusBar(
      brightness: Brightness.dark,
      child: BlocListener<DialerCubit, DialerState>(
        listener: _onDialerStateChanged,
        child: BlocBuilder<CallerCubit, CallerState>(
          builder: (context, state) {
            final callerCubit = context.watch<CallerCubit>();
            final dialerCubit = context.watch<DialerCubit>();
            final appName = context.brand.appName;

            return SafeArea(
              child: ConditionalPlaceholder(
                showPlaceholder: state is NoPermission,
                placeholder: Warning(
                  title: Text(
                    context.msg.main.dialer.noPermission.title,
                  ),
                  description: state is NoPermission && !state.dontAskAgain
                      ? Text(
                          context.msg.main.dialer.noPermission
                              .description(appName),
                        )
                      : Text(
                          context.msg.main.dialer.noPermission
                              .permanentDescription(appName),
                        ),
                  icon: const Icon(VialerSans.missedCall),
                  children: <Widget>[
                    const SizedBox(height: 40),
                    StylizedButton.raised(
                      colored: true,
                      onPressed: state is NoPermission && !state.dontAskAgain
                          ? callerCubit.requestPermission
                          : callerCubit.openAppSettings,
                      child: state is NoPermission && !state.dontAskAgain
                          ? Text(
                              context
                                  .msg.main.dialer.noPermission.buttonPermission
                                  .toUpperCaseIfAndroid(context),
                            )
                          : Text(
                              context.msg.main.dialer.noPermission
                                  .buttonOpenSettings
                                  .toUpperCaseIfAndroid(context),
                            ),
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    if (context.isAndroid) ...[
                      T9ContactsListView(controller: _dialPadController),
                      const Divider(
                        height: 1,
                        thickness: 1,
                      ),
                    ] else if (context.isIOS)
                      const SafeArea(
                        child: SizedBox(
                          height: 48,
                        ),
                      ),
                    Expanded(
                      child: DialPad(
                        controller: _dialPadController,
                        primaryButton: _CallButton(
                          onPressed: () => {_call(context)},
                        ),
                        onDeleteAll: dialerCubit.clearLastCalledDestination,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData? callButtonIcon;

  const _CallButton({Key? key, this.onPressed, this.callButtonIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // On iOS we want the call button to be the same size as the
    // other buttons. Even though we set the max size as the min size,
    // a ConstrainedBox will never impose impossible constraints, so it's not
    // a problem. In this case, it basically means: 'Biggest size possible, but
    // with a certain limit'.
    final minSize = context.isIOS ? KeypadValueButton.maxSize : 64.0;

    return Center(
      child: CallButton.call(
        constraints: BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
        onPressed: onPressed,
        icon: callButtonIcon
      ),
    );
  }
}
