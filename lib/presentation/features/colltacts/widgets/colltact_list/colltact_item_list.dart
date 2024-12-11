import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/widgets.dart';
import 'package:vialer/presentation/features/colltacts/widgets/colltact_list/colltact_bloc_builder.dart';
import 'package:vialer/presentation/features/colltacts/widgets/colltact_list/group_header.dart';
import 'package:vialer/presentation/features/colltacts/widgets/colltact_list/item.dart';
import 'package:vialer/presentation/features/colltacts/widgets/colltact_list/util/search.dart';
import 'package:vialer/presentation/util/contact.dart';

import '../../../../../../data/models/colltacts/colltact.dart';
import '../../../../../../data/models/colltacts/contact.dart';
import '../../../../../../data/models/colltacts/shared_contacts/shared_contact.dart';
import '../../../../../../data/models/relations/colleagues/colleague.dart';
import '../../../../../../domain/usecases/colltacts/get_contact_sort.dart';
import '../../../../util/pigeon.dart';
import '../../controllers/colleagues/cubit.dart';
import '../../controllers/contacts/state.dart';
import '../../controllers/shared_contacts/cubit.dart';
import 'alphabet_list.dart';
import 'no_results.dart';
import 'util/kind.dart';
import 'widget.dart';

class ColltactItemList extends StatelessWidget {
  ColltactItemList(
    this.kind, {
    super.key,
  });

  final ColltactKind kind;

  @override
  Widget build(BuildContext context) {
    final searchTerm = ColltactTabsInheritedWidget.of(context).searchTerm;
    final bottomLettersPadding =
        ColltactTabsInheritedWidget.of(context).bottomLettersPadding;

    return ColltactBlocBuilder(
      builder: (container) {
        final colltacts = <Colltact>[];
        final contactsState = container.contactsState;
        final colleaguesState = container.colleaguesState;
        final sharedContactsState = container.sharedContactsState;

        if (kind == ColltactKind.contact) {
          final contacts = contactsState is ContactsLoaded
              ? contactsState.contacts
              : <Contact>[];
          for (final contact in contacts) {
            colltacts.add(Colltact.contact(contact));
          }
        } else if (kind == ColltactKind.colleague) {
          final colleagues = colleaguesState is ColleaguesLoaded
              ? colleaguesState.filteredColleagues
              : <Colleague>[];
          for (final colleague in colleagues) {
            colltacts.add(Colltact.colleague(colleague));
          }
        } else {
          final sharedContacts = sharedContactsState is SharedContactsLoaded
              ? sharedContactsState.sharedContacts
              : <SharedContact>[];
          for (final sharedContact in sharedContacts) {
            colltacts.add(Colltact.sharedContact(sharedContact));
          }
        }

        final colleaguesUpToDate = kind == ColltactKind.colleague &&
            colleaguesState is ColleaguesLoaded &&
            colleaguesState.upToDate;

        final widgets = _mapAndFilterToWidgets(
          colltacts,
          contactsState is ContactsLoaded
              ? contactsState.contactSort
              : defaultContactSort,
          colleaguesUpToDate,
          searchTerm,
        );

        Future<void> onRefresh() async {
          await container.colleaguesCubit.refresh();
          await container.contactsCubit.reloadContacts();
          await container.sharedContactsCubit.loadSharedContacts(
            fullRefresh: true,
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.decelerate,
          switchOutCurve: Curves.decelerate.flipped,
          child: NoResultsPlaceholder(
            type: _noResultsType(
              widgets,
              contactsState,
              colleaguesState,
              container.colleaguesCubit,
              sharedContactsState,
              container.sharedContactsCubit,
              kind,
              searchTerm,
            ),
            kind: kind,
            searchTerm: searchTerm,
            onCall: (number) => unawaited(
              kind == ColltactKind.contact
                  ? container.contactsCubit.call(number)
                  : container.colleaguesCubit.call(number),
            ),
            dontAskForContactsPermissionAgain:
                contactsState is ContactsLoaded && contactsState.dontAskAgain,
            contactsCubit: container.contactsCubit,
            onRefresh: onRefresh,
            child: AlphabetListView(
              key: ValueKey(searchTerm),
              bottomLettersPadding: bottomLettersPadding,
              onRefresh: onRefresh,
              children: widgets,
            ),
          ),
        );
      },
    );
  }

  /// Inspects the current state and determines why we aren't able to show
  /// any results for the selected list. This is then passed to
  /// [NoResultsPlaceholder] to render something useful for the user.
  NoResultsType? _noResultsType(
    List<Widget> records,
    ContactsState contactsState,
    ColleaguesState colleaguesState,
    ColleaguesCubit colleaguesCubit,
    SharedContactsState sharedContactsState,
    SharedContactsCubit sharedContactsCubit,
    ColltactKind colltactKind,
    String searchTerm,
  ) {
    final hasSearchQuery = searchTerm.isNotEmpty;

    switch (colltactKind) {
      case ColltactKind.contact:
        if (contactsState is LoadingContacts) {
          return NoResultsType.contactsLoading;
        } else if (contactsState is ContactsLoaded &&
            contactsState.noContactPermission) {
          return NoResultsType.noContactsPermission;
        } else if (records.isEmpty) {
          return hasSearchQuery
              ? NoResultsType.noSearchResults
              : NoResultsType.noContactsExist;
        }

        return null;
      case ColltactKind.colleague:
        if (colleaguesState is LoadingColleagues) {
          return NoResultsType.colleaguesLoading;
        } else if (colleaguesState.showOnlineColleaguesOnly &&
            !hasSearchQuery &&
            records.isEmpty) {
          return NoResultsType.noOnlineColleagues;
        }

        return hasSearchQuery && records.isEmpty
            ? NoResultsType.noSearchResults
            : null;

      case ColltactKind.sharedContact:
        if (sharedContactsState is LoadingSharedContacts) {
          return NoResultsType.sharedContactsLoading;
        } else if (!hasSearchQuery && records.isEmpty) {
          return NoResultsType.noSharedContactsExist;
        }
        return hasSearchQuery && records.isEmpty
            ? NoResultsType.noSearchResults
            : null;
    }
  }

  List<Widget> _mapAndFilterToWidgets(
    Iterable<Colltact> colltacts,
    ContactSort contactSort,
    bool colleaguesUpToDate,
    String? searchTerm,
  ) {
    final groupedColltacts = <String, List<Colltact>>{};

    /// Whether the [char] is part of the *letter group*, which consists of
    /// any letter in any language (including non-latin alphabets)
    bool isInLetterGroup(String? char) =>
        char != null && RegExp(r'\p{L}', unicode: true).hasMatch(char);

    searchTerm = searchTerm?.toLowerCase();

    for (final colltact in colltacts) {
      if (searchTerm != null && !colltact.matchesSearchTerm(searchTerm)) {
        continue;
      }

      final firstCharacter = _firstCharacterForSorting(colltact, contactSort);

      /// Group letters case sensitive with or without diacritics together.
      final groupCharacter =
          removeDiacritics(firstCharacter ?? '').toUpperCase();

      if (isInLetterGroup(groupCharacter)) {
        groupedColltacts[groupCharacter] ??= [];
        groupedColltacts[groupCharacter]!.add(colltact);
      } else {
        groupedColltacts[nonLetterKey] ??= [];
        groupedColltacts[nonLetterKey]!.add(colltact);
      }
    }

    return _createSortedColltactList(
      groupedColltacts,
      contactSort,
      colleaguesUpToDate,
    );
  }

  String? _firstCharacterForSorting(
    Colltact colltact,
    ContactSort contactSort,
  ) {
    return colltact.when(
      colleague: (colleague) {
        var firstCharacter = colleague.name.characters.firstOrNull;
        if (firstCharacter.isNullOrEmpty &&
            !colleague.number.isNotNullOrEmpty) {
          firstCharacter = colleague.number!.characters.firstOrDefault('');
        }
        return firstCharacter;
      },
      contact: (contact) {
        var firstCharacter = contactSort.orderBy == OrderBy.familyName
            ? contact.familyName?.characters.firstOrNull ??
                contact.displayName.characters.firstOrNull
            : contact.givenName?.characters.firstOrNull ??
                contact.displayName.characters.firstOrNull;
        if (firstCharacter.isNullOrEmpty && contact.phoneNumbers.isNotEmpty) {
          firstCharacter =
              contact.phoneNumbers.first.value.characters.firstOrDefault('');
        }
        return firstCharacter;
      },
      sharedContact: (sharedContact) =>
          sharedContact.displayName.characters.firstOrNull,
    );
  }

  List<Widget> _createSortedColltactList(
    Map<String, List<Colltact>> colltacts,
    ContactSort contactSort,
    bool colleaguesUpToDate,
  ) {
    return [
      // Sort all colltacts with a letter alphabetically.
      ...colltacts.entries
          .filter((e) => e.key != nonLetterKey)
          .sortedBy((e) => e.key),
      // Place all colltacts that belong to the non-letter group at the bottom.
      ...colltacts.entries.filter((e) => e.key == nonLetterKey),
    ]
        .map(
          (e) => [
            GroupHeader(group: e.key),
            ...e.value
                .sortedBy((colltact) => colltact.getSortKey(contactSort))
                .map(
                  (colltact) => ColltactItem.from(
                    colltact,
                    colleaguesUpToDate: colleaguesUpToDate,
                  ),
                ),
          ],
        )
        .flatten()
        .toList();
  }
}

const nonLetterKey = '#';
