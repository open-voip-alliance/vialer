import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../domain/entities/contact.dart';
import '../../../resources/localizations.dart';
import '../../../resources/theme.dart';
import '../../../util/brand.dart';
import '../../../util/conditional_capitalization.dart';
import '../../../util/contact.dart';
import '../../../util/extensions.dart';
import '../../../util/pigeon.dart';
import '../../../util/widgets_binding_observer_registrar.dart';
import '../../../widgets/stylized_button.dart';
import '../widgets/conditional_placeholder.dart';
import '../widgets/header.dart';
import 'cubit.dart';
import 'widgets/group_header.dart';
import 'widgets/item.dart';

abstract class ContactsPageRoutes {
  static const root = '/';
  static const details = '/details';
}

class ContactsPage extends StatefulWidget {
  final double bottomLettersPadding;

  const ContactsPage({
    Key? key,
    this.bottomLettersPadding = 0,
  }) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactsPage>
    with WidgetsBindingObserver, WidgetsBindingObserverRegistrar {
  String? _searchTerm;

  void _onSearchTermChanged(String searchTerm) {
    setState(() {
      _searchTerm = searchTerm;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      context.read<ContactsCubit>().reloadContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16,
          ),
          child: BlocBuilder<ContactsCubit, ContactsState>(
            builder: (context, state) {
              final cubit = context.watch<ContactsCubit>();

              return Column(
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
                  Expanded(
                    child: _Placeholder(
                      state: state,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.decelerate,
                        switchOutCurve: Curves.decelerate.flipped,
                        child: _AlphabetListView(
                          key: ValueKey(_searchTerm),
                          bottomLettersPadding: widget.bottomLettersPadding,
                          children: _mapAndFilterToWidgets(
                            state is ContactsLoaded ? state.contacts : [],
                            state is ContactsLoaded ? state.contactSort : null,
                          ),
                          onRefresh: cubit.reloadContacts,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _mapAndFilterToWidgets(
    Iterable<Contact> contacts,
    ContactSort? contactSort,
  ) {
    final widgets = <String, List<ContactItem>>{};

    const nonLetterKey = '#';

    /// Whether the [char] is part of the *letter group*, which consists of
    /// any letter in any language (including non-latin alphabets)
    bool isInLetterGroup(String? char) =>
        char != null ? RegExp(r'\p{L}', unicode: true).hasMatch(char) : false;

    final searchTerm = _searchTerm?.toLowerCase();
    for (var contact in contacts) {
      if (searchTerm != null &&
          !contact.displayName.toLowerCase().contains(searchTerm) &&
          !contact.emails.any(
            (email) => email.value.toLowerCase().contains(searchTerm),
          ) &&
          !contact.phoneNumbers.any(
            (number) => number.value.toLowerCase().replaceAll(' ', '').contains(
                  searchTerm.formatForPhoneNumberQuery(),
                ),
          )) {
        continue;
      }

      final contactItem = ContactItem(contact: contact);

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

    return [
      // Sort all contact widgets with a letter alphabetically.
      ...widgets.entries
          .filter((e) => e.key != nonLetterKey)
          .sortedBy((e) => e.key),
      // Place all contacts that belong to the non-letter group at the bottom.
      ...widgets.entries.filter((e) => e.key == nonLetterKey).toList(),
    ]
        .map(
          (e) => [
            GroupHeader(group: e.key),
            // Sort the contacts within the group by family- or given name
            // or as fallback by the display name.
            ...e.value.sortedBy(
              (e) => ((contactSort!.orderBy == OrderBy.familyName
                          ? e.contact.familyName
                          : e.contact.givenName) ??
                      e.contact.displayName)
                  .toLowerCase(),
            )
          ],
        )
        .flatten()
        .toList();
  }
}

class _Placeholder extends StatelessWidget {
  final ContactsState state;
  final Widget child;

  const _Placeholder({
    Key? key,
    required this.state,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Needed for auto cast
    final state = this.state;

    final cubit = context.watch<ContactsCubit>();
    final appName = context.brand.appName;

    return ConditionalPlaceholder(
      showPlaceholder: state is! ContactsLoaded || state.contacts.isEmpty,
      placeholder: SingleChildScrollView(
        child: state is NoPermission
            ? Warning(
                icon: const Icon(VialerSans.lockOn),
                title: Text(
                  context.msg.main.contacts.list.noPermission.title(appName),
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
                            context.msg.main.contacts.list.noPermission
                                .buttonPermission
                                .toUpperCaseIfAndroid(context),
                          )
                        : Text(
                            context.msg.main.contacts.list.noPermission
                                .buttonOpenSettings
                                .toUpperCaseIfAndroid(context),
                          ),
                  ),
                ],
              )
            : state is LoadingContacts
                ? LoadingIndicator(
                    title: Text(
                      context.msg.main.contacts.list.loading.title,
                    ),
                    description: Text(
                      context.msg.main.contacts.list.loading.description,
                    ),
                  )
                : Warning(
                    icon: const Icon(VialerSans.userOff),
                    title: Text(
                      context.msg.main.contacts.list.empty.title,
                    ),
                    description: Text(
                      context.msg.main.contacts.list.empty.description(
                        context.brand.appName,
                      ),
                    ),
                  ),
      ),
      child: child,
    );
  }
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
            color: context.brand.theme.grey5,
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
      cursorColor: context.brand.theme.primary,
      controller: _searchController,
      decoration: InputDecoration(
        filled: true,
        fillColor: context.brand.theme.grey3,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          gapPadding: 0,
        ),
        prefixIcon: Icon(
          VialerSans.search,
          size: 20,
          color: context.brand.theme.grey4,
        ),
        suffixIcon: _canClear
            ? IconButton(
                onPressed: _handleClear,
                icon: Icon(
                  VialerSans.close,
                  size: 20,
                  color: context.brand.theme.grey4,
                ),
              )
            : null,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
