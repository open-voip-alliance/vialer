import 'dart:async';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

/// Avatar used in Contacts and Recents.
class Avatar extends StatefulWidget {
  const Avatar({
    super.key,
    this.name,
    this.image,
    this.size = defaultSize,
    this.foregroundColor = Colors.white,
    this.backgroundColor,
    this.showFallback,
    this.fallback,
  });

  static const defaultSize = 36.0;

  final String? name;
  final File? image;

  final Color? foregroundColor;
  final Color? backgroundColor;
  final double size;

  /// Whether to show the [fallback]. By default this is true when [name]
  /// and [image] are null.
  final bool? showFallback;

  /// Fallback shown [showFallback] is true.
  final Widget? fallback;

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  late final String _letters = _initLetters();

  String _initLetters() {
    final letters = widget.name!
        .split(' ')
        .map((word) => word.characters.firstOrDefault('').toUpperCase());

    if (letters.length == 1) {
      return letters.first;
    } else {
      return letters.first + letters.last;
    }
  }

  File? _existingImage;

  @override
  void initState() {
    super.initState();

    unawaited(
      widget.image?.exists().then((exists) {
        if (exists) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            setState(() {
              _existingImage = widget.image;
            });
          });
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final existingImage = _existingImage;
    final hasImage = existingImage != null;
    final showFallback =
        widget.showFallback ?? widget.name == null && !hasImage;

    return Container(
      width: widget.size,
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: CircleAvatar(
          foregroundColor: widget.foregroundColor,
          backgroundColor: widget.backgroundColor,
          backgroundImage: hasImage ? FileImage(existingImage) : null,
          child: showFallback
              ? _withStyle(widget.fallback)
              : widget.name != null && !hasImage
                  ? _withStyle(Text(_letters))
                  : null, //  We show the avatar.
        ),
      ),
    );
  }

  Widget? _withStyle(Widget? child) {
    if (child == null) return null;

    return DefaultTextStyle.merge(
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20 * (widget.size / Avatar.defaultSize),
      ),
      child: child,
    );
  }
}
