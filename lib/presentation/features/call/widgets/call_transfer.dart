import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recase/recase.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../data/models/colltacts/colltact.dart';
import '../../../../global.dart';
import '../../../shared/widgets/nested_navigator.dart';
import '../../../shared/widgets/t9_dial_pad.dart';
import '../../colltacts/widgets/colltact_list/details/widget.dart';
import '../../colltacts/widgets/colltact_list/widget.dart';
import 'call_header_container.dart';
import 'call_transfer_bar.dart';

class CallTransfer extends StatefulWidget {
  const CallTransfer({
    required this.activeCall,
    required this.onTransferTargetSelected,
    required this.onContactsButtonPressed,
    required this.onCloseButtonPressed,
    super.key,
  });

  final Call activeCall;
  final void Function(String) onTransferTargetSelected;
  final void Function() onContactsButtonPressed;
  final void Function() onCloseButtonPressed;

  @override
  State<CallTransfer> createState() => _CallTransferState();
}

class _CallTransferState extends State<CallTransfer> {
  static const _dialPadRoute = '/';
  static const _colltactsRoute = '/colltacts';

  final _navigatorKey = GlobalKey<NavigatorState>();

  void _onCloseButtonPressed(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> _onContactsButtonPressed(BuildContext context) async {
    final number =
        (await Navigator.pushNamed(context, _colltactsRoute))! as String;
    widget.onTransferTargetSelected(number);
  }

  void _onColltactPhoneNumberPressed(
    BuildContext context,
    Colltact colltact,
    String number,
  ) {
    track('call-transfer-initiated', {
      'via': ReCase(colltact.runtimeType.toString()).paramCase,
    });
    Navigator.pop(context, number);
  }

  void _onDialPadCallButtonPressed(String number) {
    track('call-transfer-initiated', {
      'via': 'dialer',
    });
    widget.onTransferTargetSelected(number);
  }

  @override
  void initState() {
    super.initState();

    track('call-transfer-ui-presented');
  }

  @override
  Widget build(BuildContext mainContext) {
    final transferToStart =
        '${mainContext.msg.main.call.ongoing.state.transferToStart} ';
    final transferToEnd =
        ' ${mainContext.msg.main.call.ongoing.state.transferToEnd}';

    const bottomIconSize = 32.0;
    final bottomIconColor = mainContext.brand.theme.colors.grey5;

    final closeButton = IconButton(
      icon: FaIcon(
        FontAwesomeIcons.xmark,
        color: bottomIconColor,
      ),
      iconSize: bottomIconSize,
      onPressed: () => _onCloseButtonPressed(mainContext),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CallHeaderContainer(
          child: SafeArea(
            child: CallTransferBar(
              text: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: transferToStart),
                    TextSpan(
                      text: widget.activeCall.remotePartyHeading,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: transferToEnd,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: NestedNavigator(
            navigatorKey: _navigatorKey,
            fullscreenDialog: true,
            routes: {
              _dialPadRoute: (context, _) {
                return T9DialPad(
                  callButtonIcon: FontAwesomeIcons.arrowRightArrowLeft,
                  callButtonColor: context.brand.theme.colors.green1,
                  callButtonSemanticsHint:
                      context.msg.main.call.ongoing.actions.transfer.label,
                  onCallButtonPressed: _onDialPadCallButtonPressed,
                  bottomLeftButton: closeButton,
                  bottomRightButton: IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.addressBook,
                      color: bottomIconColor,
                    ),
                    iconSize: bottomIconSize,
                    onPressed: () => unawaited(
                      _onContactsButtonPressed(context),
                    ),
                  ),
                );
              },
              _colltactsRoute: (routeContext, _) {
                return Material(
                  child: Column(
                    children: [
                      Expanded(
                        child: ColltactList(
                          detailsBuilder: (context, colltact) {
                            return ColltactDetails(
                              colltact: colltact,
                              onPhoneNumberPressed: (number) =>
                                  _onColltactPhoneNumberPressed(
                                routeContext,
                                colltact,
                                number,
                              ),
                              onEmailPressed: (_) {},
                            );
                          },
                        ),
                      ),
                      Material(
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              closeButton,
                              IconButton(
                                icon: Icon(
                                  Icons.dialpad,
                                  color: bottomIconColor,
                                ),
                                iconSize: bottomIconSize,
                                onPressed: () => Navigator.pop(routeContext),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            },
          ),
        ),
      ],
    );
  }
}
