import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

/// Avatar used in Contacts and Recents.
class Avatar extends StatelessWidget {
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

  const Avatar({
    Key? key,
    this.name,
    this.image,
    this.size = defaultSize,
    this.foregroundColor = Colors.white,
    this.backgroundColor,
    this.showFallback,
    this.fallback,
  }) : super(key: key);

  String get _letters {
    final letters = name!
        .split(' ')
        .map((word) => word.characters.firstOrDefault('').toUpperCase());

    if (letters.length == 1) {
      return letters.first;
    } else {
      return letters.first + letters.last;
    }
  }

  Future<bool> get hasImage async =>
      image != null && image?.existsSync() == true;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: hasImage,
      builder: (context, snapshot) {
        final hasImage = snapshot.data ?? false;
        final showFallback = this.showFallback ?? name == null && !hasImage;

        return Container(
          width: size,
          alignment: Alignment.center,
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: CircleAvatar(
              foregroundColor: foregroundColor,
              backgroundColor: backgroundColor,
              backgroundImage: hasImage ? FileImage(image!) : null,
              child: showFallback
                  ? _withStyle(fallback)
                  : name != null && !hasImage
                      ? _withStyle(Text(_letters))
                      : null, //  We show the avatar.
            ),
          ),
        );
      },
    );
  }

  Widget? _withStyle(Widget? child) {
    if (child == null) return null;

    return DefaultTextStyle.merge(
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20 * (size / defaultSize),
      ),
      child: child,
    );
  }
}
