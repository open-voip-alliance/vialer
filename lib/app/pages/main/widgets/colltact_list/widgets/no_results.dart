import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../resources/localizations.dart';
import '../../../../../resources/theme.dart';
import '../../../../../util/conditional_capitalization.dart';
import '../../../../../widgets/stylized_button.dart';
import '../../../../../widgets/universal_refresh_indicator.dart';
import '../../conditional_placeholder.dart';
import '../cubit.dart';
import '../widget.dart';

class NoResultsPlaceholder extends StatelessWidget {
  /// The type of NoResults page to display, if set to [null] then none will be
  /// displayed.
  final NoResultsType? type;
  final String searchTerm;
  final ColltactKind kind;
  final Function(String number) onCall;
  final Future<void> Function() onRefresh;
  final bool dontAskForContactsPermissionAgain;
  final ColltactsCubit cubit;
  final Widget child;

  const NoResultsPlaceholder({
    required this.type,
    required this.searchTerm,
    required this.kind,
    required this.onCall,
    required this.onRefresh,
    required this.dontAskForContactsPermissionAgain,
    required this.cubit,
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
      case NoResultsType.colleaguesLoading:
        return context.msg.main.contacts.list.loadingColleagues.title;
      case NoResultsType.contactsLoading:
        return context.msg.main.contacts.list.loadingContacts.title;
      case NoResultsType.noContactsExist:
        return context.msg.main.contacts.list.empty.title;
      case NoResultsType.noContactsPermission:
        return context.msg.main.contacts.list.noPermission
            .description(context.brand.appName);
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
      case NoResultsType.colleaguesLoading:
        return context.msg.main.contacts.list.loadingColleagues.description;
      case NoResultsType.contactsLoading:
        return context.msg.main.contacts.list.loadingContacts.description;
      case NoResultsType.noContactsExist:
        return context.msg.main.contacts.list.empty.description(
          context.brand.appName,
        );
      case NoResultsType.noContactsPermission:
        return context.msg.main.contacts.list.noPermission
            .permanentDescription(context.brand.appName);
    }
  }

  Widget? _button(BuildContext context) {
    if (type == NoResultsType.noContactsPermission) {
      return _ContactsPermissionButton(
        dontAskAgain: dontAskForContactsPermissionAgain,
        cubit: cubit,
      );
    }

    if (_shouldShowCallButton) {
      return _CallButton(searchTerm: searchTerm, onCall: onCall);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (type == null) return child;

    if (type == NoResultsType.contactsLoading ||
        type == NoResultsType.colleaguesLoading) {
      return LoadingIndicator(
        title: Text(_title(context)),
        description: Text(_subtitle(context)),
      );
    }

    return UniversalRefreshIndicator(
      onRefresh: onRefresh,
      child: KeyboardVisibilityBuilder(
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
                  child: _button(context),
                ),
              ],
            ),
          );
        },
      ),
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
      case NoResultsType.colleaguesLoading:
      case NoResultsType.contactsLoading:
        return FontAwesomeIcons.abacus;
      case NoResultsType.noContactsExist:
        return FontAwesomeIcons.userSlash;
      case NoResultsType.noContactsPermission:
        return FontAwesomeIcons.lock;
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
  colleaguesLoading,
  contactsLoading,
  noContactsExist,
  noContactsPermission,
}

class _ContactsPermissionButton extends StatelessWidget {
  final bool dontAskAgain;
  final ColltactsCubit cubit;

  _ContactsPermissionButton({
    required this.dontAskAgain,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return StylizedButton.raised(
      colored: true,
      onPressed: dontAskAgain ? cubit.requestPermission : cubit.openAppSettings,
      child: !dontAskAgain
          ? Text(
              context.msg.main.contacts.list.noPermission.buttonPermission
                  .toUpperCaseIfAndroid(context),
            )
          : Text(
              context.msg.main.contacts.list.noPermission.buttonOpenSettings
                  .toUpperCaseIfAndroid(context),
            ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final String searchTerm;
  final Function(String number) onCall;

  _CallButton({
    required this.searchTerm,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return StylizedButton.raised(
      colored: true,
      onPressed: () => onCall(searchTerm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(FontAwesomeIcons.phone, size: 16),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              context.msg.main.colltacts.noResults.button(searchTerm),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
