import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:characters/characters.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:provider/provider.dart';

import '../../../resources/localizations.dart';

import '../../../../domain/entities/contact.dart';

import '../../../../domain/repositories/permission.dart';
import '../../../../domain/repositories/contact.dart';

import '../../../resources/theme.dart';

import '../../../widgets/stylized_button.dart';
import '../widgets/header.dart';
import '../widgets/list_placeholder.dart';
import 'widgets/item.dart';
import 'widgets/letter_header.dart';

import '../../../util/conditional_capitalization.dart';

import 'controller.dart';

abstract class ContactsPageRoutes {
  static const root = '/';
  static const details = '/details';
}

class ContactsPage extends View {
  final ContactRepository _contactsRepository;
  final PermissionRepository _permissionRepository;

  final double bottomLettersPadding;

  ContactsPage(
    this._contactsRepository,
    this._permissionRepository, {
    Key key,
    this.bottomLettersPadding = 0,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContactPageState(
        _contactsRepository,
        _permissionRepository,
      );
}

class _ContactPageState extends ViewState<ContactsPage, ContactsController> {
  _ContactPageState(
    ContactRepository contactRepository,
    PermissionRepository permissionRepository,
  ) : super(ContactsController(contactRepository, permissionRepository));

  @override
  Widget buildPage() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Header(context.msg.main.contacts.title),
              ),
              Expanded(
                child: ConditionalPlaceholder(
                  showPlaceholder: controller.contacts.isEmpty,
                  placeholder: controller.hasPermission
                      ? ListPlaceholder(
                          icon: Icon(VialerSans.userOff),
                          title: Text(
                            context.msg.main.contacts.list.empty.title,
                          ),
                          description: Text(
                            context.msg.main.contacts.list.empty.description,
                          ),
                        )
                      : ListPlaceholder(
                          icon: Icon(VialerSans.lockOn),
                          title: Text(
                            context.msg.main.contacts.list.noPermission.title,
                          ),
                          description: Text(
                            context.msg.main.contacts.list.noPermission
                                .description,
                          ),
                          children: <Widget>[
                            SizedBox(height: 40),
                            StylizedButton.raised(
                              colored: true,
                              onPressed: controller.askPermission,
                              child: Text(
                                context
                                    .msg.main.contacts.list.noPermission.button
                                    .toUpperCaseIfAndroid(context),
                              ),
                            ),
                          ],
                        ),
                  child: _AlphabetListView(
                    bottomLettersPadding: widget.bottomLettersPadding,
                    children: _mapToWidgets(controller.contacts),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _mapToWidgets(Iterable<Contact> contacts) {
    final widgets = <String, List<ContactItem>>{};

    const numberKey = '#';
    const specialKey = '&';

    bool isAlpha(String char) =>
        char != null ? RegExp(r'\p{L}', unicode: true).hasMatch(char) : false;

    bool isNumberlike(String char) =>
        char != null ? RegExp(r'[0-9\(\+]').hasMatch(char) : false;

    for (var contact in contacts) {
      var firstCharacter = contact.initials.characters.firstWhere(
        (_) => true,
        orElse: () => null,
      );

      final contactItem = ContactItem(contact: contact);

      // Check special groups
      if (isNumberlike(firstCharacter)) {
        widgets[numberKey] ??= [];
        widgets[numberKey].add(contactItem);
      } else if (isAlpha(firstCharacter)) {
        widgets[firstCharacter] ??= [];
        widgets[firstCharacter].add(contactItem);
      } else {
        widgets[specialKey] ??= [];
        widgets[specialKey].add(contactItem);
      }
    }

    final sortedEntries = widgets.entries.toList()
      ..sort((a, b) {
        if (a.key == numberKey) {
          return 1;
        } else if (a.key == specialKey) {
          return -1;
        } else {
          return a.key.compareTo(b.key);
        }
      });

    return sortedEntries
        .map(
          (e) => [
            GroupHeader(group: e.key),
            ...e.value
              ..sort((a, b) => a.contact.name.compareTo(b.contact.name)),
          ],
        )
        .expand((widgets) => widgets)
        .toList();
  }
}

class _AlphabetListView extends StatefulWidget {
  final double bottomLettersPadding;
  final List<Widget> children;

  const _AlphabetListView({
    Key key,
    this.bottomLettersPadding,
    this.children,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AlphabetListViewState();
}

class _AlphabetListViewState extends State<_AlphabetListView> {
  static const _floatingLetterSize = Size(36, 36);

  final _controller = ItemScrollController();

  Offset _offset;
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

  void _onDragUpdate(DragUpdateDetails details, {@required Size parentSize}) {
    setState(() {
      _offset = details.localPosition;
      _letterMarkerVisible = true;
    });

    final letter = _letterAt(_offset, parentSize: parentSize);
    final index = widget.children
        .indexWhere((w) => w is GroupHeader && w.group == letter);

    _controller.jumpTo(index: index);
  }

  void _onDragCancel() => setState(() {
        _letterMarkerVisible = false;
      });

  String _letterAt(Offset offset, {@required Size parentSize}) {
    final size = _sideLetterSize(parentSize);

    final usableParentHeight = parentSize.height - widget.bottomLettersPadding;
    final lettersFullHeight = _letters.length * size.height;

    final offsetY = _offset.dy - (usableParentHeight - lettersFullHeight) / 2;

    var index = ((offsetY - (size.height / 2)) / size.height).round();

    index = index.clamp(0, max(0, _letters.length - 1));

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
          overflow: Overflow.visible,
          children: <Widget>[
            ScrollablePositionedList.builder(
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
            if (showLetters)
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onVerticalDragStart: showLetters ? _onDragStart : null,
                  onVerticalDragUpdate: showLetters
                      ? (d) => _onDragUpdate(d, parentSize: maxSize)
                      : null,
                  onVerticalDragEnd:
                      showLetters ? (_) => _onDragCancel() : null,
                  onVerticalDragCancel: showLetters ? _onDragCancel : null,
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
                top: _offset.dy - (_floatingLetterSize.height / 2),
                right: 48,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.decelerate,
                  opacity: _letterMarkerVisible ? 1 : 0,
                  child: SizedBox.fromSize(
                    size: _floatingLetterSize,
                    child: Center(
                      child: Text(
                        _letterAt(_offset, parentSize: maxSize),
                        style: TextStyle(
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
    Key key,
    @required this.size,
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
            color: context.brandTheme.grey5,
          ),
        ),
      ),
    );
  }
}
