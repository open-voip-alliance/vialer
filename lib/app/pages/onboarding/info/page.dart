import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:vialer/app/resources/theme.dart';

import '../../../resources/localizations.dart';
import '../../../util/conditional_capitalization.dart';
import '../../../widgets/stylized_button.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
    super.key,
  });

  static const keys = _Keys();

  final Widget icon;
  final String title;
  final Widget description;
  final VoidCallback onPressed;

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final _headerKey = GlobalKey();
  var _hasResetSemantics = false;

  @override
  void initState() {
    super.initState();
    _focusSemanticsOnHeader();
  }

  @override
  Widget build(BuildContext context) {
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: 64 * sizeFactor,
                        bottom: 24,
                      ),
                      child: IconTheme(
                        data: IconTheme.of(context).copyWith(size: 54).copyWith(
                              color: context.brand.theme.colors.primary,
                            ),
                        child: widget.icon,
                      ),
                    ),
                    Flexible(
                      child: Semantics(
                        header: true,
                        child: AutoSizeText(
                          key: _headerKey,
                          widget.title,
                          minFontSize: 28,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.brand.theme.colors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 18,
                        color:
                            context.brand.theme.colors.userAvailabilityOffline,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 24,
                          bottom: 24,
                        ),
                        child: widget.description,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Semantics(
            excludeSemantics: !_hasResetSemantics,
            button: true,
            child: StylizedButton.raised(
              colored: true,
              key: InfoPage.keys.continueButton,
              onPressed: widget.onPressed,
              child: Text(
                context.msg.onboarding.permission.button.iUnderstand
                    .toUpperCaseIfAndroid(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A hacky way to resolve an issue where the screen reader would
  /// stay focused on the continue button rather than returning to the header
  /// when navigating to the next page.
  ///
  /// See #1715 for more info.
  void _focusSemanticsOnHeader() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _headerKey.currentContext
          ?.findRenderObject()
          ?.sendSemanticsEvent(const FocusSemanticEvent());

      await Future<void>.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() => _hasResetSemantics = true);
      }
    });
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

  Key get continueButton => const Key('continueButton');
}
