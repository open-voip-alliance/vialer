import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../../../resources/theme/brand_theme.dart';
import '../../../../../../util/brand.dart';
import 'group_header.dart';

class AlphabetListView extends StatefulWidget {
  const AlphabetListView({
    required this.bottomLettersPadding,
    required this.children,
    required this.onRefresh,
    super.key,
  });

  final double bottomLettersPadding;
  final List<Widget> children;
  final Future<void> Function() onRefresh;

  @override
  State<StatefulWidget> createState() => _AlphabetListViewState();
}

class _AlphabetListViewState extends State<AlphabetListView> {
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
  const _SideLetter(
    this.letter, {
    required this.size,
  });

  static const fontSize = 10.0;

  final String letter;
  final Size size;

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
