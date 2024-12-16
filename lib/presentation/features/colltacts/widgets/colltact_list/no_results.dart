import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/theme.dart';
import 'package:vialer/presentation/util/conditional_capitalization.dart';

import '../../../../resources/localizations.dart';
import '../../../../shared/widgets/conditional_placeholder.dart';
import '../../../../shared/widgets/stylized_button.dart';
import '../../../../shared/widgets/universal_refresh_indicator.dart';
import '../../../../util/circular_graphic.dart';
import '../../../settings/widgets/settings_button.dart';
import '../../controllers/contacts/cubit.dart';
import '../../controllers/shared_contacts/cubit.dart';
import '../../pages/add_shared_contact/page.dart';
import 'util/kind.dart';

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
            .description(context.brand.appName),
        NoResultsType.noSharedContactsExist =>
          context.msg.main.contacts.list.emptySharedContacts.title,
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
            .permanentDescription(context.brand.appName),
        NoResultsType.noSharedContactsExist => context
            .msg.main.contacts.list.emptySharedContacts
            .description(context.brand.appName),
      };

  Widget? _button(BuildContext context) {
    if (type == NoResultsType.noContactsPermission) {
      return _ContactsPermissionButton(
        dontAskAgain: dontAskForContactsPermissionAgain,
        cubit: contactsCubit,
      );
    } else if (type == NoResultsType.noSharedContactsExist) {
      return _CreateSharedContactButton();
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
        type == NoResultsType.colleaguesLoading ||
        type == NoResultsType.sharedContactsLoading) {
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
                    child: !isKeyboardVisible
                        ? CircularGraphic(type!.iconData)
                        : null,
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

enum NoResultsType {
  noOnlineColleagues,
  noSearchResults,
  colleaguesLoading,
  contactsLoading,
  sharedContactsLoading,
  noSharedContactsExist,
  noContactsExist,
  noContactsPermission,
}

extension on NoResultsType {
  IconData get iconData => switch (this) {
        NoResultsType.noSearchResults => FontAwesomeIcons.magnifyingGlass,
        NoResultsType.colleaguesLoading ||
        NoResultsType.contactsLoading ||
        NoResultsType.sharedContactsLoading =>
          FontAwesomeIcons.abacus,
        NoResultsType.noContactsExist ||
        NoResultsType.noSharedContactsExist ||
        NoResultsType.noOnlineColleagues =>
          FontAwesomeIcons.userSlash,
        NoResultsType.noContactsPermission => FontAwesomeIcons.lock,
      };
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
      onPressed: dontAskAgain ? cubit.openAppSettings : cubit.requestPermission,
      text: dontAskAgain
          ? context.msg.main.contacts.list.noPermission.buttonOpenSettings
          : context.msg.main.contacts.list.noPermission.buttonPermission,
    );
  }
}

class _CreateSharedContactButton extends StatelessWidget {
  const _CreateSharedContactButton();

  @override
  Widget build(BuildContext context) {
    return SettingsButton(
      onPressed: () => unawaited(
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return AddSharedContactPage(
                onSave: () => context
                    .read<SharedContactsCubit>()
                    .loadSharedContacts(fullRefresh: true),
              );
            },
          ),
        ),
      ),
      solid: false,
      icon: FontAwesomeIcons.userPlus,
      text: context.msg.main.contacts.list.createSharedContactButton.title
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
