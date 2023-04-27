import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_lib/flutter_phone_lib.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/conditional_capitalization.dart';
import '../../widgets/avatar.dart';
import '../../widgets/caller.dart';
import '../widgets/call_button.dart';

class IncomingCallPage extends StatefulWidget {
  const IncomingCallPage({super.key});

  @override
  State<StatefulWidget> createState() => _IncomingCallPageState();
}

class _IncomingCallPageState extends State<IncomingCallPage>
    with TickerProviderStateMixin {
  void _onDeclineButtonPressed() {
    context.read<CallerCubit>().endVoipCall();
  }

  void _onAnswerButtonPressed() {
    context.read<CallerCubit>().answerVoipCall();
  }

  @override
  Widget build(BuildContext context) {
    final outerCircleColor =
        context.brand.theme.colors.primaryLight.withOpacity(0.4);
    const outerCirclePadding = EdgeInsets.all(32);

    return WillPopScope(
      // Incoming call page can never be popped by the user.
      onWillPop: () => SynchronousFuture(false),
      child: Scaffold(
        body: Stack(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.9,
                  colors: [
                    context.brand.theme.colors.primary,
                    context.brand.theme.colors.primary.withOpacity(0),
                  ],
                ),
              ),
              child: Center(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    applyElevationOverlayColor: true,
                  ),
                  child: Material(
                    shape: const CircleBorder(),
                    color: outerCircleColor,
                    elevation: 2,
                    shadowColor:
                        context.brand.theme.colors.primary.withOpacity(0.4),
                    child: Padding(
                      padding: outerCirclePadding,
                      child: Material(
                        shape: const CircleBorder(),
                        color: outerCircleColor,
                        child: Padding(
                          padding: outerCirclePadding,
                          child: Material(
                            shape: const CircleBorder(),
                            color: outerCircleColor.withOpacity(1),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Icon(
                                // This will be replaced with an animation,
                                // which resembles the brand icon.
                                context.brand.icon,
                                size: 56,
                                color: context.brand.theme.colors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 48,
              right: 48,
              top: 48 + MediaQuery.of(context).viewInsets.top,
              child: BlocBuilder<CallerCubit, CallerState>(
                builder: (context, state) {
                  if (state is CallProcessState) {
                    return _Info(
                      call: state.voipCall!,
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    label: Text(
                      context.msg.main.call.incoming.decline
                          .toUpperCaseIfAndroid(context),
                      style: TextStyle(
                        color: context.brand.theme.colors.primaryDark,
                      ),
                    ),
                    child: CallButton.decline(
                      heroTag: null,
                      onPressed: _onDeclineButtonPressed,
                    ),
                  ),
                  const SizedBox(width: 96),
                  _ActionButton(
                    label: Text(
                      context.msg.main.call.incoming.answer
                          .toUpperCaseIfAndroid(context),
                      style: TextStyle(
                        color: context.brand.theme.colors.primaryDark,
                      ),
                    ),
                    child: CallButton.answer(
                      heroTag: null,
                      onPressed: _onAnswerButtonPressed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({
    required this.call,
  });

  final Call call;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(context.brand.theme.logo),
            const SizedBox(width: 8),
            Text(
              context.brand.appName,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Material(
              shape: const CircleBorder(),
              elevation: 4,
              child: Avatar(
                name: call.remotePartyHeading,
                foregroundColor: context.brand.theme.colors.primary,
                backgroundColor: Colors.white,
                showFallback: call.contact?.name == null,
                fallback: const FaIcon(FontAwesomeIcons.phone, size: 16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    call.remotePartyHeading,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.phoneArrowDownLeft,
                        size: 12,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          call.remotePartySubheading.isNotBlank
                              ? context.msg.main.call.incoming
                                  .subtitleWith(call.remotePartySubheading)
                              : context.msg.main.call.incoming.subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.child,
  });

  final Widget label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: context.brand.theme.colors.onPrimary,
          ),
          child: label,
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}
