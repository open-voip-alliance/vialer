import 'package:flutter/material.dart';

import '../../../resources/localizations.dart';
import '../../../util/conditional_capitalization.dart';
import '../../../widgets/stylized_button.dart';

class InfoPage extends StatelessWidget {
  static const keys = _Keys();

  final Widget icon;
  final Widget title;
  final Widget description;
  final VoidCallback onPressed;

  InfoPage({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final sizeFactor = context.sizeFactor;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 48,
      ).copyWith(
        bottom: 24,
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (n) {
                // Remove scroll glow on Android.
                n.disallowIndicator();
                return false;
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: 64 * sizeFactor,
                        bottom: 24,
                      ),
                      child: IconTheme(
                        data: IconTheme.of(context).copyWith(size: 54),
                        child: icon,
                      ),
                    ),
                    MediaQuery(
                      data: mediaQuery.copyWith(
                        // Title should never get bigger than it already is,
                        // even on max font size.
                        textScaleFactor: mediaQuery.textScaleFactor.clamp(0, 1),
                      ),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          // Scale down the title based on the screen width.
                          fontSize: 40 * sizeFactor,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        child: title,
                      ),
                    ),
                    DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 24,
                          bottom: 24,
                        ),
                        child: description,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          StylizedButton.raised(
            key: keys.continueButton,
            onPressed: onPressed,
            child: Text(
              context.msg.onboarding.permission.button.iUnderstand
                  .toUpperCaseIfAndroid(context),
            ),
          ),
        ],
      ),
    );
  }
}

extension on BuildContext {
  /// The size factor to scale down widgets based on the available screen space.
  // The number `416` is just a magic value to use as a "default"
  // screen width, if the actual screen width is below this value,
  // the size factor will be less than 1, meaning the
  // widgets will get scaled down.
  //
  // The default screen width value is loosely based
  // on the Nexus 5X screen width.
  double get sizeFactor => (MediaQuery.of(this).size.width / 416)
  // On bigger (or extremely small) screens, the
  // values are clamped to prevent extreme sizes.
      .clamp(0.5, 1);
}

class _Keys {
  const _Keys();

  final continueButton = const Key('continueButton');
}
