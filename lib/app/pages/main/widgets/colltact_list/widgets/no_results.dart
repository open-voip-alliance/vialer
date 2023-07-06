import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../resources/localizations.dart';
import '../../../../../resources/theme.dart';
import '../../../../../util/conditional_capitalization.dart';
import '../../../../../widgets/stylized_button.dart';
import '../../../../../widgets/universal_refresh_indicator.dart';
import '../../../settings/widgets/buttons/settings_button.dart';
import '../../conditional_placeholder.dart';
import '../cubit.dart';
import '../widget.dart';

class NoResultsPlaceholder extends StatelessWidget {
  const NoResultsPlaceholder({
    required this.type,
    required this.searchTerm,
    required this.kind,
    required this.onCall,
    required this.onRefresh,
    required this.dontAskForContactsPermissionAgain,
    required this.contactsCubit,
    required this.child,
    super.key,
  });

  /// The type of NoResults page to display, if set to `null` then none will be
  /// displayed.
  final NoResultsType? type;
  final String searchTerm;
  final ColltactKind kind;
  final void Function(String number) onCall;
  final Future<void> Function() onRefresh;
  final bool dontAskForContactsPermissionAgain;
  final ContactsCubit contactsCubit;
  final Widget child;

  /// The call button should only be shown when the text field looks like a
  /// valid number.
  bool get _shouldShowCallButton =>
      type == NoResultsType.noSearchResults &&
      searchTerm.isNotEmpty &&
      searchTerm.length <= 13 &&
      !RegExp('[^0-9+ ]').hasMatch(searchTerm);

  String _title(BuildContext context) => switch (type!) {
        NoResultsType.noOnlineColleagues =>
          context.msg.main.colltacts.noOnline.title,
        NoResultsType.noSearchResults =>
          context.msg.main.colltacts.noResults.title,
        NoResultsType.colleaguesLoading =>
          context.msg.main.contacts.list.loadingColleagues.title,
        NoResultsType.contactsLoading =>
          context.msg.main.contacts.list.loadingContacts.title,
        NoResultsType.sharedContactsLoading =>
          context.msg.main.contacts.list.loadingSharedContacts.title,
        NoResultsType.noContactsExist =>
          context.msg.main.contacts.list.empty.title,
        NoResultsType.noContactsPermission => context
            .msg.main.contacts.list.noPermission
            .description(context.brand.appName)
      };

  String _subtitle(BuildContext context) => switch (type!) {
        NoResultsType.noOnlineColleagues =>
          context.msg.main.colltacts.noOnline.subtitle,
        NoResultsType.noSearchResults => switch (kind) {
            ColltactKind.contact =>
              context.msg.main.colltacts.noResults.contacts(searchTerm),
            ColltactKind.colleague =>
              context.msg.main.colltacts.noResults.colleagues(searchTerm),
            ColltactKind.sharedContact =>
              context.msg.main.colltacts.noResults.sharedContacts(searchTerm),
          },
        NoResultsType.colleaguesLoading =>
          context.msg.main.contacts.list.loadingColleagues.description,
        NoResultsType.contactsLoading =>
          context.msg.main.contacts.list.loadingContacts.description,
        NoResultsType.sharedContactsLoading =>
          context.msg.main.contacts.list.loadingSharedContacts.description,
        NoResultsType.noContactsExist =>
          context.msg.main.contacts.list.empty.description(
            context.brand.appName,
          ),
        NoResultsType.noContactsPermission => context
            .msg.main.contacts.list.noPermission
            .permanentDescription(context.brand.appName)
      };

  Widget? _button(BuildContext context) {
    if (type == NoResultsType.noContactsPermission) {
      return _ContactsPermissionButton(
        dontAskAgain: dontAskForContactsPermissionAgain,
        cubit: contactsCubit,
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: isKeyboardVisible
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
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
            ),
          );
        },
      ),
    );
  }
}

class _CircularGraphic extends StatelessWidget {
  const _CircularGraphic(this.type);

  final NoResultsType type;

  IconData _icon() {
    switch (type) {
      case NoResultsType.noOnlineColleagues:
        return FontAwesomeIcons.usersSlash;
      case NoResultsType.noSearchResults:
        return FontAwesomeIcons.magnifyingGlass;
      case NoResultsType.colleaguesLoading:
      case NoResultsType.contactsLoading:
      case NoResultsType.sharedContactsLoading:
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
        shadowColor: context.brand.theme.colors.primary.withOpacity(0),
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
  colleaguesLoading,
  contactsLoading,
  sharedContactsLoading,
  noContactsExist,
  noContactsPermission,
}

class _ContactsPermissionButton extends StatelessWidget {
  const _ContactsPermissionButton({
    required this.dontAskAgain,
    required this.cubit,
  });

  final bool dontAskAgain;
  final ContactsCubit cubit;

  @override
  Widget build(BuildContext context) {
    return SettingsButton(
      onPressed: dontAskAgain ? cubit.requestPermission : cubit.openAppSettings,
      text: !dontAskAgain
          ? context.msg.main.contacts.list.noPermission.buttonPermission
              .toUpperCaseIfAndroid(context)
          : context.msg.main.contacts.list.noPermission.buttonOpenSettings
              .toUpperCaseIfAndroid(context),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.searchTerm,
    required this.onCall,
  });

  final String searchTerm;
  final void Function(String number) onCall;

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
