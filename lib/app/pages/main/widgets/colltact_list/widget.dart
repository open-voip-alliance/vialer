import 'package:dartx/dartx.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/models/colltact.dart';
import '../../../../../domain/colltacts/contact.dart';
import '../../../../../domain/colltacts/get_contact_sort.dart';
import '../../../../../domain/user_availability/colleagues/colleague.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/contact.dart';
import '../../../../util/extensions.dart';
import '../../../../util/pigeon.dart';
import '../../../../util/widgets_binding_observer_registrar.dart';
import '../../colltacts/colleagues/cubit.dart';
import '../bottom_toggle.dart';
import '../caller.dart';
import '../header.dart';
import '../nested_navigator.dart';
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
  final GlobalKey<NavigatorState>? navigatorKey;
  final WidgetWithColltactBuilder detailsBuilder;
  final double bottomLettersPadding;

  const ColltactList({
    Key? key,
    this.navigatorKey,
    required this.detailsBuilder,
    this.bottomLettersPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ContactsCubit>(
          create: (_) => ContactsCubit(
            context.watch<CallerCubit>(),
          ),
        ),
        BlocProvider<ColleagueCubit>(
          create: (_) => ColleagueCubit(
            context.watch<CallerCubit>(),
          ),
        ),
      ],
      child: NestedNavigator(
        navigatorKey: navigatorKey,
        routes: {
          ColltactsPageRoutes.root: (_, __) => const _ColltactList(),
          ColltactsPageRoutes.details: (context, colltact) =>
              detailsBuilder(context, colltact as Colltact),
        },
      ),
    );
  }
}

class _ColltactList extends StatefulWidget {
  final double bottomLettersPadding;

  const _ColltactList({
    Key? key,
    // ignore: unused_element
    this.bottomLettersPadding = 0,
  }) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    if (context.read<ColleagueCubit>().canViewColleagues) {
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
      context.read<ColleagueCubit>().loadColleagues();
      context.read<ContactsCubit>().reloadContacts();
    }
  }

  void _createTabController() {
    final tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );

    tabController.addListener(
      () {
        if (!tabController.indexIsChanging) {
          if (tabController.index == 1) {
            context.read<ColleagueCubit>().trackColleaguesTabSelected();
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
      child: BlocBuilder<ContactsCubit, ContactState>(
        builder: (context, contactState) {
          return BlocBuilder<ColleagueCubit, ColleagueState>(
            builder: (context, colleagueState) {
              final contactsCubit = context.watch<ContactsCubit>(); //wip
              final colleagueCubit = context.watch<ColleagueCubit>();

              return DefaultTabController(
                length: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Header(context.msg.main.contacts.title),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SearchTextField(
                        onChanged: _onSearchTermChanged,
                      ),
                    ),
                    if (colleagueCubit.shouldShowColleagues)
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
                        unselectedLabelColor: context.brand.theme.colors.grey1,
                        indicatorColor: Theme.of(context).primaryColor,
                        indicatorSize: TabBarIndicatorSize.label,
                        tabs: [
                          Text(
                            context.msg.main.contacts.tabBar.contactsTabTitle
                                .toUpperCase(),
                          ),
                          Text(
                            context.msg.main.contacts.tabBar.colleaguesTabTitle
                                .toUpperCase(),
                          ),
                        ],
                      ),
                    Expanded(
                      child: colleagueCubit.shouldShowColleagues
                          ? TabBarView(
                              controller: tabController,
                              children: [
                                _animatedSwitcher(
                                  ColltactKind.contact,
                                  contactState,
                                  contactsCubit,
                                  colleagueState,
                                  colleagueCubit,
                                ),
                                Column(
                                  children: [
                                    Expanded(
                                      child: _animatedSwitcher(
                                        ColltactKind.colleague,
                                        contactState,
                                        contactsCubit,
                                        colleagueState,
                                        colleagueCubit,
                                      ),
                                    ),
                                    BottomToggle(
                                      name: context.msg.main.colleagues.toggle,
                                      initialValue: colleagueCubit
                                          .showOnlineColleaguesOnly,
                                      onChanged: (enabled) {
                                        colleagueCubit
                                            .showOnlineColleaguesOnly = enabled;
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : _animatedSwitcher(
                              ColltactKind.contact,
                              contactState,
                              contactsCubit,
                              colleagueState,
                              colleagueCubit,
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _mapAndFilterToWidgets(
    ColltactKind kind, //wip wont be needed anymore
    Iterable<Colltact> colltacts,
    ContactSort contactSort,
  ) {
    final groupedColltacts = <String, List<Colltact>>{};

    /// Whether the [char] is part of the *letter group*, which consists of
    /// any letter in any language (including non-latin alphabets)
    bool isInLetterGroup(String? char) =>
        char != null ? RegExp(r'\p{L}', unicode: true).hasMatch(char) : false;

    final searchTerm = _searchTerm?.toLowerCase();

    final contactsOnly =
        kind == ColltactKind.contact; //wip wont be needed anymore

    for (var colltact in colltacts) {
      if ((!contactsOnly && colltact is ColltactContact) ||
          (contactsOnly && colltact is ColltactColleague)) {
        continue;
      } //wip wont be needed anymore

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

    return _createSortedColltactList(groupedColltacts, contactSort);
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
    );
  }

  List<Widget> _createSortedColltactList(
    Map<String, List<Colltact>> colltacts,
    ContactSort contactSort,
  ) {
    return [
      // Sort all colltacts with a letter alphabetically.
      ...colltacts.entries
          .filter((e) => e.key != nonLetterKey)
          .sortedBy((e) => e.key),
      // Place all colltacts that belong to the non-letter group at the bottom.
      ...colltacts.entries.filter((e) => e.key == nonLetterKey).toList(),
    ]
        .map(
          (e) => [
            GroupHeader(group: e.key),
            ...e.value
                .sortedBy((colltact) => colltact.getSortKey(contactSort))
                .map(ColltactItem.from)
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
    ContactState contactState,
    ColleagueState colleagueState,
    ColleagueCubit colleagueCubit,
    ColltactKind colltactKind,
  ) {
    final hasSearchQuery = _searchTerm?.isNotEmpty == true;

    switch (colltactKind) {
      case ColltactKind.contact:
        if (contactState is LoadingContacts) {
          return NoResultsType.contactsLoading;
        } else if (contactState is ContactsLoaded &&
            contactState.noContactPermission) {
          return NoResultsType.noContactsPermission;
        } else if (records.isEmpty) {
          return hasSearchQuery
              ? NoResultsType.noSearchResults
              : NoResultsType.noContactsExist;
        }

        return null;
      case ColltactKind.colleague:
        if (colleagueState is Loading) {
          return NoResultsType.colleaguesLoading;
        } else if (colleagueState is WebSocketUnreachable) {
          return NoResultsType.noColleagueConnectivity;
        } else if (colleagueCubit.showOnlineColleaguesOnly &&
            !hasSearchQuery &&
            records.isEmpty) {
          return NoResultsType.noOnlineColleagues;
        }

        return hasSearchQuery && records.isEmpty
            ? NoResultsType.noSearchResults
            : null;
    }
  }

  AnimatedSwitcher _animatedSwitcher(
    ColltactKind colltactKind,
    ContactState contactState,
    ContactsCubit contactsCubit,
    ColleagueState colleagueState,
    ColleagueCubit colleagueCubit,
  ) {
    var colltacts = <Colltact>[];

    if (colltactKind == ColltactKind.contact) {
      final contacts =
          contactState is ContactsLoaded ? contactState.contacts : <Contact>[];
      for (var contact in contacts) {
        colltacts.add(Colltact.contact(contact));
      }
    } else {
      final colleagues =
          colleagueState is Loaded ? colleagueState.colleagues : <Colleague>[];
      for (var colleague in colleagues) {
        colltacts.add(Colltact.colleague(colleague));
      }
    }

    final records = _mapAndFilterToWidgets(
      colltactKind,
      colltacts,
      contactState is ContactsLoaded
          ? contactState.contactSort
          : defaultContactSort,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.decelerate,
      switchOutCurve: Curves.decelerate.flipped,
      child: NoResultsPlaceholder(
        type: _noResultsType(
          records,
          contactState,
          colleagueState,
          colleagueCubit,
          colltactKind,
        ),
        kind: colltactKind,
        searchTerm: _searchTerm ?? '',
        onCall: (number) => colltactKind == ColltactKind.contact
            ? contactsCubit.call(number)
            : colleagueCubit.call(number),
        dontAskForContactsPermissionAgain:
            contactState is ContactsLoaded ? contactState.dontAskAgain : false,
        contactsCubit: contactsCubit,
        child: AlphabetListView(
          key: ValueKey(_searchTerm),
          bottomLettersPadding: widget.bottomLettersPadding,
          children: records,
          onRefresh: () async {
            await colleagueCubit.loadColleagues();
            await contactsCubit.reloadContacts();
          },
        ),
      ),
    );
  }
}

enum ColltactKind {
  contact,
  colleague,
}

extension on Colltact {
  bool matchesSearchTerm(String term) {
    return when(
      colleague: (colleague) {
        if (colleague.name.toLowerCase().contains(term)) return true;

        if ((colleague.number ?? '').toLowerCase().replaceAll(' ', '').contains(
              term.formatForPhoneNumberQuery(),
            )) return true;

        return false;
      },
      contact: (contact) {
        if (contact.displayName.toLowerCase().contains(term)) return true;

        if (contact.company?.toLowerCase().contains(term) == true) return true;

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
    );
  }
}
