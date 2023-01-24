import 'package:dartx/dartx.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/models/colltact.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/contact.dart';
import '../../../../util/extensions.dart';
import '../../../../util/pigeon.dart';
import '../../../../util/widgets_binding_observer_registrar.dart';
import '../../colltacts/colleagues/cubit.dart';
import '../bottom_toggle.dart';
import '../caller.dart';
import '../conditional_placeholder.dart';
import '../header.dart';
import '../nested_navigator.dart';
import 'cubit.dart';
import 'widgets/alphabet_list.dart';
import 'widgets/colltact_placeholder.dart';
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
    return BlocProvider<ColltactsCubit>(
      create: (_) => ColltactsCubit(
        context.watch<ColleagueCubit>(),
        context.watch<CallerCubit>(),
      ),
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
    if (context.read<ColltactsCubit>().canViewColleagues) {
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
      context.read<ColltactsCubit>().reloadColltacts();
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
            context.read<ColltactsCubit>().trackColleaguesTabSelected();
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
      child: BlocBuilder<ColltactsCubit, ColltactsState>(
        builder: (context, state) {
          final cubit = context.watch<ColltactsCubit>();

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
                if (cubit.shouldShowColleagues)
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
                      Text(context.msg.main.contacts.tabBar.colleaguesTabTitle
                          .toUpperCase()),
                    ],
                  ),
                Expanded(
                  child: cubit.shouldShowColleagues
                      ? TabBarView(
                          controller: tabController,
                          children: [
                            _animatedSwitcher(
                                ColltactKind.contact, state, cubit),
                            Column(
                              children: [
                                Expanded(
                                  child: _animatedSwitcher(
                                    ColltactKind.colleague,
                                    state,
                                    cubit,
                                  ),
                                ),
                                BottomToggle(
                                  name: context.msg.main.colleagues.toggle,
                                  initialValue: cubit.showOnlineColleaguesOnly,
                                  onChanged: (enabled) {
                                    cubit.showOnlineColleaguesOnly = enabled;
                                  },
                                ),
                              ],
                            ),
                          ],
                        )
                      : _animatedSwitcher(ColltactKind.contact, state, cubit),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _mapAndFilterToContactWidgets(
    Iterable<Colltact> colltacts,
    ContactSort? contactSort,
  ) {
    final widgets = <String, List<ColltactItem>>{};

    /// Whether the [char] is part of the *letter group*, which consists of
    /// any letter in any language (including non-latin alphabets)
    bool isInLetterGroup(String? char) =>
        char != null ? RegExp(r'\p{L}', unicode: true).hasMatch(char) : false;

    final searchTerm = _searchTerm?.toLowerCase();
    for (var colltact in colltacts) {
      if (colltact is ColltactContact) {
        final contact = colltact.contact;

        if (searchTerm != null && !colltact.matchesSearchTerm(searchTerm)) {
          continue;
        }

        final contactItem = ColltactItem(colltact: colltact);

        /// Grouping contacts is based on the first letter of the
        /// given-, family-, or display name or if that fails phone number.
        var firstCharacter = contactSort!.orderBy == OrderBy.familyName
            ? contact.familyName?.characters.firstOrNull ??
                contact.displayName.characters.firstOrNull
            : contact.givenName?.characters.firstOrNull ??
                contact.displayName.characters.firstOrNull;

        if (firstCharacter.isNullOrEmpty && contact.phoneNumbers.isNotEmpty) {
          firstCharacter =
              contact.phoneNumbers.first.value.characters.firstOrDefault('');
        }

        /// Group letters case sensitive with or without diacritics together.
        final groupCharacter =
            removeDiacritics(firstCharacter ?? '').toUpperCase();

        if (isInLetterGroup(groupCharacter)) {
          widgets[groupCharacter] ??= [];
          widgets[groupCharacter]!.add(contactItem);
        } else {
          widgets[nonLetterKey] ??= [];
          widgets[nonLetterKey]!.add(contactItem);
        }
      }
    }

    return _createSortedColltactList(widgets, contactSort);
  }

  List<Widget> _mapAndFilterToColleagueWidgets(
    Iterable<Colltact> colltacts,
  ) {
    final widgets = <String, List<ColltactItem>>{};

    /// Whether the [char] is part of the *letter group*, which consists of
    /// any letter in any language (including non-latin alphabets)
    bool isInLetterGroup(String? char) =>
        char != null ? RegExp(r'\p{L}', unicode: true).hasMatch(char) : false;

    final searchTerm = _searchTerm?.toLowerCase();

    for (var colltact in colltacts) {
      if (colltact is ColltactColleague) {
        final colleague = colltact.colleague;

        if (searchTerm != null && !colltact.matchesSearchTerm(searchTerm)) {
          continue;
        }

        final contactItem = ColltactItem(colltact: colltact);

        var firstCharacter = colleague.name.characters.firstOrNull;

        if (firstCharacter.isNullOrEmpty &&
            !colleague.number.isNotNullOrEmpty) {
          firstCharacter = colleague.number!.characters.firstOrDefault('');
        }

        /// Group letters case sensitive with or without diacritics together.
        final groupCharacter =
            removeDiacritics(firstCharacter ?? '').toUpperCase();

        if (isInLetterGroup(groupCharacter)) {
          widgets[groupCharacter] ??= [];
          widgets[groupCharacter]!.add(contactItem);
        } else {
          widgets[nonLetterKey] ??= [];
          widgets[nonLetterKey]!.add(contactItem);
        }
      }
    }

    return _createSortedColltactList(widgets, null);
  }

  List<Widget> _createSortedColltactList(
    Map<String, List<ColltactItem>> widgets,
    ContactSort? contactSort,
  ) {
    return [
      // Sort all colltact widgets with a letter alphabetically.
      ...widgets.entries
          .filter((e) => e.key != nonLetterKey)
          .sortedBy((e) => e.key),
      // Place all colltacts that belong to the non-letter group at the bottom.
      ...widgets.entries.filter((e) => e.key == nonLetterKey).toList(),
    ]
        .map(
          (e) => [
            GroupHeader(group: e.key),
            ...e.value.sortedBy(
              (e) => ((e.colltact.when(
                colleague: (colleague) => colleague.name,
                // Sort the contacts within the group by family or given name
                // or as fallback by the display name.
                contact: (contact) =>
                    ((contactSort!.orderBy == OrderBy.familyName
                                ? contact.familyName
                                : contact.givenName) ??
                            contact.displayName)
                        .toLowerCase(),
              ))),
            )
          ],
        )
        .flatten()
        .toList();
  }

  NoResultsType? _noResultsType(List<Widget> records, ColltactsCubit cubit) {
    if (records.isNotEmpty) return null;

    final hasSearchQuery = _searchTerm?.isNotEmpty == true;

    if (cubit.showOnlineColleaguesOnly && !hasSearchQuery) {
      return NoResultsType.noOnlineColleagues;
    }

    return hasSearchQuery ? NoResultsType.noSearchResults : null;
  }

  AnimatedSwitcher _animatedSwitcher(
    ColltactKind colltactKind,
    ColltactsState state,
    ColltactsCubit cubit,
  ) {
    final isForContacts = colltactKind == ColltactKind.contact;

    final records = isForContacts
        ? _mapAndFilterToContactWidgets(
            state is ColltactsLoaded ? state.colltacts : [],
            state is ColltactsLoaded ? state.contactSort : null,
          )
        : _mapAndFilterToColleagueWidgets(
            state is ColltactsLoaded ? state.colltacts : [],
          );

    final list = NoResultsPlaceholder(
      type: _noResultsType(records, cubit),
      kind: colltactKind,
      searchTerm: _searchTerm ?? '',
      onCall: (number) => cubit.call(
        number,
        origin: isForContacts ? CallOrigin.contacts : CallOrigin.colleagues,
      ),
      child: AlphabetListView(
        key: ValueKey(_searchTerm),
        bottomLettersPadding: widget.bottomLettersPadding,
        children: records,
        onRefresh: () async {
          await cubit.refreshColleagues();
          await cubit.reloadColltacts();
        },
      ),
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.decelerate,
      switchOutCurve: Curves.decelerate.flipped,
      child: isForContacts
          ? ConditionalPlaceholder(
              showPlaceholder: state is ColltactsLoaded &&
                  (state.colltacts.isEmpty || state.noContactPermission),
              placeholder: ColltactsPlaceholder(cubit: cubit, state: state),
              child: list,
            )
          : list,
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
