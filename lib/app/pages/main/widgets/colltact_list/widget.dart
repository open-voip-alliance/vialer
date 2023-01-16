import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../../data/models/colltact.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/conditional_capitalization.dart';
import '../../../../util/contact.dart';
import '../../../../util/extensions.dart';
import '../../../../util/pigeon.dart';
import '../../../../util/widgets_binding_observer_registrar.dart';
import '../../../../widgets/stylized_button.dart';
import '../../colltacts/colleagues/cubit.dart';
import '../conditional_placeholder.dart';
import '../header.dart';
import '../nested_navigator.dart';
import 'cubit.dart';
import 'widgets/group_header.dart';
import 'widgets/item.dart';

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
      create: (_) => ColltactsCubit(context.watch<ColleagueCubit>()),
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
                  child: _SearchTextField(
                    onChanged: _onSearchTermChanged,
                  ),
                ),
                if (cubit.shouldShowColleagues)
                  TabBar(
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
                      ? TabBarView(children: [
                          _animatedSwitcher(ColltactKind.contact, state, cubit),
                          _animatedSwitcher(
                              ColltactKind.colleague, state, cubit),
                        ])
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

  AnimatedSwitcher _animatedSwitcher(
      ColltactKind colltactKind, ColltactsState state, ColltactsCubit cubit) {
    final isForContacts = colltactKind == ColltactKind.contact;
    final appName = context.brand.appName;

    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.decelerate,
        switchOutCurve: Curves.decelerate.flipped,
        child: isForContacts
            ? ConditionalPlaceholder(
                showPlaceholder: state is ColltactsLoaded &&
                    (state.colltacts.isEmpty || state.noContactPermission),
                placeholder: SingleChildScrollView(
                  child: state is ColltactsLoaded && state.noContactPermission
                      ? Warning(
                          icon: const FaIcon(FontAwesomeIcons.lock),
                          title: Text(
                            context.msg.main.contacts.list.noPermission
                                .title(appName),
                          ),
                          description: !state.dontAskAgain
                              ? Text(
                                  context.msg.main.contacts.list.noPermission
                                      .description(appName),
                                )
                              : Text(
                                  context.msg.main.contacts.list.noPermission
                                      .permanentDescription(appName),
                                ),
                          children: <Widget>[
                            const SizedBox(height: 40),
                            StylizedButton.raised(
                              colored: true,
                              onPressed: !state.dontAskAgain
                                  ? cubit.requestPermission
                                  : cubit.openAppSettings,
                              child: !state.dontAskAgain
                                  ? Text(
                                      context.msg.main.contacts.list
                                          .noPermission.buttonPermission
                                          .toUpperCaseIfAndroid(context),
                                    )
                                  : Text(
                                      context.msg.main.contacts.list
                                          .noPermission.buttonOpenSettings
                                          .toUpperCaseIfAndroid(context),
                                    ),
                            ),
                          ],
                        )
                      : state is LoadingColltacts
                          ? LoadingIndicator(
                              title: Text(
                                context.msg.main.contacts.list.loading.title,
                              ),
                              description: Text(
                                context
                                    .msg.main.contacts.list.loading.description,
                              ),
                            )
                          : Warning(
                              icon: const FaIcon(FontAwesomeIcons.userSlash),
                              title: Text(
                                context.msg.main.contacts.list.empty.title,
                              ),
                              description: Text(
                                context.msg.main.contacts.list.empty
                                    .description(
                                  context.brand.appName,
                                ),
                              ),
                            ),
                ),
                child: _AlphabetListView(
                  key: ValueKey(_searchTerm),
                  bottomLettersPadding: widget.bottomLettersPadding,
                  children: _mapAndFilterToContactWidgets(
                    state is ColltactsLoaded ? state.colltacts : [],
                    state is ColltactsLoaded ? state.contactSort : null,
                  ),
                  onRefresh: cubit.reloadColltacts,
                ),
              )
            : _AlphabetListView(
                key: ValueKey(_searchTerm),
                bottomLettersPadding: widget.bottomLettersPadding,
                children: _mapAndFilterToColleagueWidgets(
                  state is ColltactsLoaded ? state.colltacts : [],
                ),
                onRefresh: cubit.reloadColltacts,
              ));
  }
}

enum ColltactKind {
  contact,
  colleague,
}

class _AlphabetListView extends StatefulWidget {
  final double bottomLettersPadding;
  final List<Widget> children;
  final Future<void> Function() onRefresh;

  const _AlphabetListView({
    Key? key,
    required this.bottomLettersPadding,
    required this.children,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AlphabetListViewState();
}

class _AlphabetListViewState extends State<_AlphabetListView> {
  static const _floatingLetterSize = Size(36, 36);

  final _controller = ItemScrollController();

  Offset? _offset;
  bool _letterMarkerVisible = false;

  List<String> get _letters =>
      widget.children.whereType<GroupHeader>().map((h) => h.group).toList();

  Size _sideLetterSize(Size parentSize) {
    final height = parentSize.height - widget.bottomLettersPadding;
    var dimension = height / _letters.length;
    dimension = max(_SideLetter.fontSize, dimension);
    dimension = min(24, dimension);

    return Size(dimension, dimension);
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _offset = details.localPosition;
    });
  }

  void _onDragUpdate(DragUpdateDetails details, {required Size parentSize}) {
    setState(() {
      _offset = details.localPosition;
      _letterMarkerVisible = true;
    });

    final letter = _letterAtCurrentOffset(parentSize: parentSize);
    final index = widget.children
        .indexWhere((w) => w is GroupHeader && w.group == letter);

    _controller.jumpTo(index: index);
  }

  void _onDragCancel() => setState(() {
        _letterMarkerVisible = false;
      });

  String _letterAtCurrentOffset({required Size parentSize}) {
    final size = _sideLetterSize(parentSize);

    final usableParentHeight = parentSize.height - widget.bottomLettersPadding;
    final lettersFullHeight = _letters.length * size.height;

    final offsetY = _offset!.dy - (usableParentHeight - lettersFullHeight) / 2;

    var index = ((offsetY - (size.height / 2)) / size.height).round();
    index = index.clamp(0, max(0, _letters.length - 1)).toInt();

    return _letters[index];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSize = constraints.biggest;
        final sideLetterSize = _sideLetterSize(maxSize);
        final showLetters = _letters.length >= 8;

        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: <Widget>[
            RefreshIndicator(
              onRefresh: widget.onRefresh,
              child: ScrollablePositionedList.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemScrollController: _controller,
                itemCount: widget.children.length,
                itemBuilder: (context, index) {
                  if (widget.children.isNotEmpty) {
                    return Provider<EdgeInsets>(
                      create: (_) => EdgeInsets.only(
                        left: 16,
                        right: 16 + sideLetterSize.width,
                      ),
                      child: widget.children[index],
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            if (showLetters)
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onVerticalDragStart: _onDragStart,
                  onVerticalDragUpdate: (d) =>
                      _onDragUpdate(d, parentSize: maxSize),
                  onVerticalDragEnd: (_) => _onDragCancel(),
                  onVerticalDragCancel: _onDragCancel,
                  child: AbsorbPointer(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: widget.bottomLettersPadding,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _letters.map(
                          (letter) {
                            return _SideLetter(letter, size: sideLetterSize);
                          },
                        ).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            if (showLetters && _offset != null)
              Positioned(
                top: _offset!.dy - (_floatingLetterSize.height / 2),
                right: 48,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.decelerate,
                  opacity: _letterMarkerVisible ? 1 : 0,
                  child: SizedBox.fromSize(
                    size: _floatingLetterSize,
                    child: Center(
                      child: Text(
                        _letterAtCurrentOffset(parentSize: maxSize),
                        style: const TextStyle(
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SideLetter extends StatelessWidget {
  static const fontSize = 10.0;

  final String letter;
  final Size size;

  const _SideLetter(
    this.letter, {
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: Center(
        child: Text(
          letter,
          textAlign: TextAlign.center,
          textScaleFactor: 1,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: context.brand.theme.colors.grey5,
          ),
        ),
      ),
    );
  }
}

class _SearchTextField extends StatefulWidget {
  final void Function(String) onChanged;

  _SearchTextField({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  _SearchTextFieldState createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<_SearchTextField> {
  final _searchController = TextEditingController();

  bool _canClear = false;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_handleSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  void _handleSearch() {
    setState(() {
      _canClear = _searchController.text.isNotEmpty;
    });

    widget.onChanged(_searchController.text);
  }

  void _handleClear() {
    _searchController.clear();

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: context.brand.theme.colors.primary,
      controller: _searchController,
      decoration: InputDecoration(
        filled: true,
        fillColor: context.brand.theme.colors.grey3,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          gapPadding: 0,
        ),
        // Must be `Icon` and not `FaIcon` because it's expected as a square.
        prefixIcon: Icon(
          FontAwesomeIcons.magnifyingGlass,
          size: 20,
          color: context.brand.theme.colors.grey4,
        ),
        suffixIcon: _canClear
            ? IconButton(
                onPressed: _handleClear,
                icon: FaIcon(
                  FontAwesomeIcons.xmark,
                  size: 20,
                  color: context.brand.theme.colors.grey4,
                ),
              )
            : null,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
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
