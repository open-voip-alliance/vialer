import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:search_highlight_text/search_highlight_text.dart';

import '../../../../../data/models/colltact.dart';
import '../../../../../domain/colltacts/colltact_tab.dart';
import '../../../../../domain/colltacts/contact.dart';
import '../../../../../domain/colltacts/get_contact_sort.dart';
import '../../../../../domain/colltacts/shared_contacts/shared_contact.dart';
import '../../../../../domain/user_availability/colleagues/colleague.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/contact.dart';
import '../../../../util/extensions.dart';
import '../../../../util/pigeon.dart';
import '../../../../util/widgets_binding_observer_registrar.dart';
import '../../../../widgets/animated_visibility.dart';
import '../../colltacts/colleagues/cubit.dart';
import '../../colltacts/shared_contacts/cubit.dart';
import '../bottom_toggle.dart';
import '../caller.dart';
import '../nested_navigator.dart';
import '../notice/widgets/banner.dart';
import 'cubit.dart';
import 'widgets/alphabet_list.dart';
import 'widgets/group_header.dart';
import 'widgets/item.dart';
import 'widgets/no_results.dart';
import 'widgets/search.dart';

abstract class ColltactsPageRoutes {
  static const root = '/';
  static const details = '/details';
}

typedef WidgetWithColltactBuilder = Widget Function(BuildContext, Colltact);

class ColltactList extends StatelessWidget {
  const ColltactList({
    required this.detailsBuilder,
    this.bottomLettersPadding = 0,
    this.navigatorKey,
    super.key,
  });

  final GlobalKey<NavigatorState>? navigatorKey;
  final WidgetWithColltactBuilder detailsBuilder;
  final double bottomLettersPadding;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ContactsCubit>(
      create: (_) => ContactsCubit(context.watch<CallerCubit>()),
      child: NestedNavigator(
        navigatorKey: navigatorKey,
        routes: {
          ColltactsPageRoutes.root: (_, __) => const _ColltactList(),
          ColltactsPageRoutes.details: (context, colltact) =>
              detailsBuilder(context, colltact! as Colltact),
        },
      ),
    );
  }
}

class _ColltactList extends StatefulWidget {
  const _ColltactList({
    // ignore: unused_element
    this.bottomLettersPadding = 0,
  });

  final double bottomLettersPadding;

  @override
  _ColltactPageState createState() => _ColltactPageState();
}

class _ColltactPageState extends State<_ColltactList>
    with
        WidgetsBindingObserver,
        WidgetsBindingObserverRegistrar,
        SingleTickerProviderStateMixin {
  String? _searchTerm;

  static const nonLetterKey = '#';

  TabController? tabController;
  int numberOfTabs = 3;

  @override
  void initState() {
    super.initState();

    if (context.read<ColleaguesCubit>().shouldShowColleagues ||
        context.read<SharedContactsCubit>().shouldShowSharedContacts) {
      _createTabController();
    }
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  void _onSearchTermChanged(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      unawaited(context.read<ContactsCubit>().reloadContacts());
      unawaited(context
          .read<SharedContactsCubit>()
          .loadSharedContacts(fullRefresh: true));
    }
  }

  void _createTabController() {
    final contactsCubit = context.read<ContactsCubit>();
    final colleaguesCubit = context.read<ColleaguesCubit>();
    final sharedContactsCubit = context.read<SharedContactsCubit>();
    final shouldShowColleagues = colleaguesCubit.shouldShowColleagues;
    final shouldShowSharedContacts =
        sharedContactsCubit.shouldShowSharedContacts;

    final storedTab = colleaguesCubit.getStoredTab();
    final initialIndex = storedTab == ColltactTab.contacts
        ? 0
        : storedTab == ColltactTab.sharedContact || !shouldShowSharedContacts
            ? 1
            : 2;

    numberOfTabs = shouldShowColleagues && shouldShowSharedContacts ? 3 : 2;

    final tabController = TabController(
      initialIndex: initialIndex,
      length: numberOfTabs,
      vsync: this,
    );

    tabController.addListener(
      () {
        if (!tabController.indexIsChanging) {
          final colleagueTabSelected =
              (tabController.index == 1 && !shouldShowSharedContacts) ||
                  tabController.index == 2;
          final contactsTabSelected = tabController.index == 0;

          colleaguesCubit.storeCurrentTab(
            colleagueTabSelected
                ? ColltactTab.colleagues
                : contactsTabSelected
                    ? ColltactTab.contacts
                    : ColltactTab.sharedContact,
          );

          if (colleagueTabSelected) {
            colleaguesCubit.trackColleaguesTabSelected();
          } else if (contactsTabSelected) {
            contactsCubit.trackContactsTabSelected();
          } else {
            sharedContactsCubit.trackSharedContactsTabSelected();
          }
        }
      },
    );

    this.tabController = tabController;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
      ),
      child: BlocBuilder<ContactsCubit, ContactsState>(
        builder: (context, contactsState) {
          return BlocBuilder<ColleaguesCubit, ColleaguesState>(
            builder: (context, colleaguesState) {
              return BlocBuilder<SharedContactsCubit, SharedContactsState>(
                builder: (context, sharedContactsState) {
                  final contactsCubit = context.watch<ContactsCubit>();
                  final colleaguesCubit = context.watch<ColleaguesCubit>();
                  final sharedContactsCubit =
                      context.watch<SharedContactsCubit>();

                  final showWebsocketUnreachableNotice =
                      colleaguesCubit.shouldShowColleagues &&
                          colleaguesState is ColleaguesLoaded &&
                          !colleaguesState.upToDate;

                  return DefaultTabController(
                    length: numberOfTabs,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: AnimatedVisibility(
                            visible: showWebsocketUnreachableNotice,
                            child: NoticeBanner(
                              icon: const FaIcon(FontAwesomeIcons.question),
                              title: Text(
                                context.msg.main.colleagues
                                    .websocketUnreachableNotice.title,
                              ),
                              content: Text(
                                context.msg.main.colleagues
                                    .websocketUnreachableNotice
                                    .content(context.brand.appName),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SearchTextField(
                            onChanged: _onSearchTermChanged,
                          ),
                        ),
                        if (colleaguesCubit.shouldShowColleagues ||
                            sharedContactsCubit.shouldShowSharedContacts)
                          TabBar(
                            controller: tabController,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            labelPadding: const EdgeInsets.only(
                              top: 18,
                              bottom: 8,
                            ),
                            labelColor: Theme.of(context).primaryColor,
                            unselectedLabelColor:
                                context.brand.theme.colors.grey1,
                            indicatorColor: Theme.of(context).primaryColor,
                            indicatorSize: TabBarIndicatorSize.label,
                            tabs: [
                              Text(
                                context
                                    .msg.main.contacts.tabBar.contactsTabTitle
                                    .toUpperCase(),
                              ),
                              if (sharedContactsCubit.shouldShowSharedContacts)
                                Text(
                                  context
                                      .msg.main.contacts.tabBar.sharedTabTitle
                                      .toUpperCase(),
                                ),
                              if (colleaguesCubit.shouldShowColleagues)
                                Text(
                                  context.msg.main.contacts.tabBar
                                      .colleaguesTabTitle
                                      .toUpperCase(),
                                ),
                            ],
                          ),
                        SearchTextInheritedWidget(
                          searchText: _searchTerm ?? '',
                          highlightStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 17,
                          ),
                          child: Expanded(
                            child: colleaguesCubit.shouldShowColleagues &&
                                    sharedContactsCubit.shouldShowSharedContacts
                                ? TabBarView(
                                    controller: tabController,
                                    children: [
                                      _animatedSwitcher(
                                        ColltactKind.contact,
                                        contactsState,
                                        contactsCubit,
                                        colleaguesState,
                                        colleaguesCubit,
                                        sharedContactsState,
                                        sharedContactsCubit,
                                      ),
                                      _animatedSwitcher(
                                        ColltactKind.sharedContact,
                                        contactsState,
                                        contactsCubit,
                                        colleaguesState,
                                        colleaguesCubit,
                                        sharedContactsState,
                                        sharedContactsCubit,
                                      ),
                                      Column(
                                        children: [
                                          Expanded(
                                            child: _animatedSwitcher(
                                              ColltactKind.colleague,
                                              contactsState,
                                              contactsCubit,
                                              colleaguesState,
                                              colleaguesCubit,
                                              sharedContactsState,
                                              sharedContactsCubit,
                                            ),
                                          ),
                                          BottomToggle(
                                            name: context
                                                .msg.main.colleagues.toggle,
                                            initialValue: colleaguesCubit
                                                .showOnlineColleaguesOnly,
                                            onChanged: (value) => colleaguesCubit
                                                    .showOnlineColleaguesOnly =
                                                value,
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : sharedContactsCubit.shouldShowSharedContacts
                                    ? TabBarView(
                                        controller: tabController,
                                        children: [
                                          _animatedSwitcher(
                                            ColltactKind.contact,
                                            contactsState,
                                            contactsCubit,
                                            colleaguesState,
                                            colleaguesCubit,
                                            sharedContactsState,
                                            sharedContactsCubit,
                                          ),
                                          _animatedSwitcher(
                                            ColltactKind.sharedContact,
                                            contactsState,
                                            contactsCubit,
                                            colleaguesState,
                                            colleaguesCubit,
                                            sharedContactsState,
                                            sharedContactsCubit,
                                          ),
                                        ],
                                      )
                                    : colleaguesCubit.shouldShowColleagues
                                        ? TabBarView(
                                            controller: tabController,
                                            children: [
                                              _animatedSwitcher(
                                                ColltactKind.contact,
                                                contactsState,
                                                contactsCubit,
                                                colleaguesState,
                                                colleaguesCubit,
                                                sharedContactsState,
                                                sharedContactsCubit,
                                              ),
                                              Column(
                                                children: [
                                                  Expanded(
                                                    child: _animatedSwitcher(
                                                      ColltactKind.colleague,
                                                      contactsState,
                                                      contactsCubit,
                                                      colleaguesState,
                                                      colleaguesCubit,
                                                      sharedContactsState,
                                                      sharedContactsCubit,
                                                    ),
                                                  ),
                                                  BottomToggle(
                                                    name: context.msg.main
                                                        .colleagues.toggle,
                                                    initialValue: colleaguesCubit
                                                        .showOnlineColleaguesOnly,
                                                    onChanged: (value) =>
                                                        colleaguesCubit
                                                                .showOnlineColleaguesOnly =
                                                            value,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        : _animatedSwitcher(
                                            ColltactKind.contact,
                                            contactsState,
                                            contactsCubit,
                                            colleaguesState,
                                            colleaguesCubit,
                                            sharedContactsState,
                                            sharedContactsCubit,
                                          ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _mapAndFilterToWidgets(
    Iterable<Colltact> colltacts,
    ContactSort contactSort,
    bool colleaguesUpToDate,
  ) {
    final groupedColltacts = <String, List<Colltact>>{};

    /// Whether the [char] is part of the *letter group*, which consists of
    /// any letter in any language (including non-latin alphabets)
    bool isInLetterGroup(String? char) =>
        char != null && RegExp(r'\p{L}', unicode: true).hasMatch(char);

    final searchTerm = _searchTerm?.toLowerCase();

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
      sharedContact: (sharedContact) {
        var firstCharacter = sharedContact.givenName?.characters.firstOrNull;
        return firstCharacter;
      },
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
                )
          ],
        )
        .flatten()
        .toList();
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
  ) {
    final hasSearchQuery = _searchTerm?.isNotEmpty ?? false;

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
        }
        return hasSearchQuery && records.isEmpty
            ? NoResultsType.noSearchResults
            : null;
    }
  }

  AnimatedSwitcher _animatedSwitcher(
    ColltactKind colltactKind,
    ContactsState contactsState,
    ContactsCubit contactsCubit,
    ColleaguesState colleaguesState,
    ColleaguesCubit colleaguesCubit,
    SharedContactsState sharedContactsState,
    SharedContactsCubit sharedContactsCubit,
  ) {
    final colltacts = <Colltact>[];

    if (colltactKind == ColltactKind.contact) {
      final contacts = contactsState is ContactsLoaded
          ? contactsState.contacts
          : <Contact>[];
      for (final contact in contacts) {
        colltacts.add(Colltact.contact(contact));
      }
    } else if (colltactKind == ColltactKind.colleague) {
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

    final colleaguesUpToDate = colltactKind == ColltactKind.colleague &&
        colleaguesState is ColleaguesLoaded &&
        colleaguesState.upToDate;

    final records = _mapAndFilterToWidgets(
      colltacts,
      contactsState is ContactsLoaded
          ? contactsState.contactSort
          : defaultContactSort,
      colleaguesUpToDate,
    );

    Future<void> onRefresh() async {
      await colleaguesCubit.refresh();
      await contactsCubit.reloadContacts();
      await sharedContactsCubit.loadSharedContacts(fullRefresh: true);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.decelerate,
      switchOutCurve: Curves.decelerate.flipped,
      child: NoResultsPlaceholder(
        type: _noResultsType(
          records,
          contactsState,
          colleaguesState,
          colleaguesCubit,
          sharedContactsState,
          sharedContactsCubit,
          colltactKind,
        ),
        kind: colltactKind,
        searchTerm: _searchTerm ?? '',
        onCall: (number) => unawaited(
          colltactKind == ColltactKind.contact
              ? contactsCubit.call(number)
              : colleaguesCubit.call(number),
        ),
        dontAskForContactsPermissionAgain:
            contactsState is ContactsLoaded && contactsState.dontAskAgain,
        contactsCubit: contactsCubit,
        onRefresh: onRefresh,
        child: AlphabetListView(
          key: ValueKey(_searchTerm),
          bottomLettersPadding: widget.bottomLettersPadding,
          onRefresh: onRefresh,
          children: records,
        ),
      ),
    );
  }
}

enum ColltactKind {
  contact,
  colleague,
  sharedContact,
}

extension on Colltact {
  bool matchesSearchTerm(String term) {
    return when(
      colleague: (colleague) {
        if (colleague.name.toLowerCase().contains(term)) return true;

        if ((colleague.number ?? '').toLowerCase().replaceAll(' ', '').contains(
              term.formatForPhoneNumberQuery(),
            )) {
          return true;
        }

        return false;
      },
      contact: (contact) {
        if (contact.displayName.toLowerCase().contains(term)) return true;
        if (contact.company?.toLowerCase().contains(term) ?? false) return true;

        if (contact.emails.any(
          (email) => email.value.toLowerCase().contains(term),
        )) {
          return true;
        }

        if (contact.phoneNumbers.any(
          (number) => number.value.toLowerCase().replaceAll(' ', '').contains(
                term.formatForPhoneNumberQuery(),
              ),
        )) {
          return true;
        }

        return false;
      },
      sharedContact: (sharedContact) {
        if (sharedContact.displayName.toLowerCase().contains(term)) return true;
        if (sharedContact.company?.toLowerCase().contains(term) ?? false)
          return true;

        for (final number in sharedContact.phoneNumbers) {
          if ((number.phoneNumberFlat ?? '').toLowerCase().contains(
                term.formatForPhoneNumberQuery(),
              )) {
            return true;
          }
        }

        return false;
      },
    );
  }
}
