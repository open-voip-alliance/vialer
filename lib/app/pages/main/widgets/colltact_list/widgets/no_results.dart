import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../resources/localizations.dart';
import '../../../../../resources/theme.dart';
import '../../../../../widgets/stylized_button.dart';
import '../widget.dart';

class NoResultsPlaceholder extends StatelessWidget {
  /// The type of NoResults page to display, if set to [null] then none will be
  /// displayed.
  final NoResultsType? type;
  final String searchTerm;
  final ColltactKind kind;
  final Function(String number) onCall;
  final Widget child;

  const NoResultsPlaceholder({
    required this.type,
    required this.searchTerm,
    required this.kind,
    required this.onCall,
    required this.child,
  });

  /// The call button should only be shown when the text field looks like a
  /// valid number.
  bool get _shouldShowCallButton =>
      type == NoResultsType.noSearchResults &&
      searchTerm.isNotEmpty &&
      searchTerm.length <= 13 &&
      !RegExp(r'[^0-9+ ]').hasMatch(searchTerm);

  String _title(BuildContext context) {
    switch (type!) {
      case NoResultsType.noOnlineColleagues:
        return context.msg.main.colltacts.noOnline.title;
      case NoResultsType.noSearchResults:
        return context.msg.main.colltacts.noResults.title;
      case NoResultsType.noColleagueConnectivity:
        return context
            .msg.main.colltacts.userAvailabilityWebSocketUnreachable.title;
    }
  }

  String _subtitle(BuildContext context) {
    switch (type!) {
      case NoResultsType.noOnlineColleagues:
        return context.msg.main.colltacts.noOnline.subtitle;
      case NoResultsType.noSearchResults:
        return kind == ColltactKind.contact
            ? context.msg.main.colltacts.noResults.contacts(searchTerm)
            : context.msg.main.colltacts.noResults.colleagues(searchTerm);
      case NoResultsType.noColleagueConnectivity:
        return context
            .msg.main.colltacts.userAvailabilityWebSocketUnreachable.subtitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (type == null) return child;

    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Column(
            mainAxisAlignment: isKeyboardVisible
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                child: !isKeyboardVisible ? _CircularGraphic(type!) : null,
              ),
              const SizedBox(height: 40),
              Text(
                _title(context),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _subtitle(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _shouldShowCallButton
                    ? StylizedButton.raised(
                        colored: true,
                        onPressed: () => onCall(searchTerm),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(FontAwesomeIcons.phone, size: 16),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                context.msg.main.colltacts.noResults
                                    .button(searchTerm),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircularGraphic extends StatelessWidget {
  final NoResultsType type;

  const _CircularGraphic(this.type);

  IconData _icon() {
    switch (type) {
      case NoResultsType.noOnlineColleagues:
        return FontAwesomeIcons.usersSlash;
      case NoResultsType.noSearchResults:
        return FontAwesomeIcons.magnifyingGlass;
      case NoResultsType.noColleagueConnectivity:
        return FontAwesomeIcons.circleExclamation;
    }
  }

  @override
  Widget build(BuildContext context) {
    final outerCircleColor =
        context.brand.theme.colors.primaryLight.withOpacity(0.4);

    return Center(
      child: Material(
        shape: const CircleBorder(),
        color: outerCircleColor,
        elevation: 2,
        shadowColor: context.brand.theme.colors.primary.withOpacity(0.0),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Material(
            shape: const CircleBorder(),
            color: outerCircleColor.withOpacity(1),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FaIcon(
                _icon(),
                size: 40,
                color: context.brand.theme.colors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum NoResultsType {
  noOnlineColleagues,
  noSearchResults,
  noColleagueConnectivity,
}
