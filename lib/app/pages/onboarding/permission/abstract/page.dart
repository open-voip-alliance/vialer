import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../info/page.dart';

import 'controller.dart';

class PermissionPage extends View {
  final Widget icon;
  final Widget title;
  final Widget description;
  final PermissionController controller;

  PermissionPage({
    Key key,
    @required this.icon,
    @required this.title,
    @required this.description,
    @required this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PermissionPageState(controller);
}

class _PermissionPageState
    extends ViewState<PermissionPage, PermissionController> {
  _PermissionPageState(PermissionController controller) : super(controller);

  @override
  Widget buildPage() {
    return InfoPage(
      icon: widget.icon,
      title: widget.title,
      description: widget.description,
      onPressed: controller.ask,
    );
  }
}
