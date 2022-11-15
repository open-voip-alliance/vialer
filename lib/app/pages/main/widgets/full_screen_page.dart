import 'package:flutter/material.dart';

/// Page designed for being full screen.
class FullScreenPage extends StatelessWidget {
  final Widget title;
  final Widget body;

  const FullScreenPage({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        centerTitle: true,
      ),
      body: body,
    );
  }
}
