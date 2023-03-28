import 'package:flutter/material.dart';
import 'header.dart';

/// Page designed for being full screen.
class FullScreenPage extends StatelessWidget {
  final String title;
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
        title: Header(title),
        titleSpacing: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: body,
    );
  }
}
