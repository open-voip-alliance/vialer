import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../resources/localizations.dart';
import '../../widgets/stylized_button.dart';

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
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 48,
      ).copyWith(
        bottom: 24,
      ),
      child: Column(
        children: <Widget>[
          SizedBox(height: 64),
          IconTheme(
            data: IconTheme.of(context).copyWith(size: 54),
            child: widget.icon,
          ),
          SizedBox(height: 24),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
            child: widget.title,
          ),
          SizedBox(height: 24),
          DefaultTextStyle(
            style: TextStyle(
              fontSize: 18,
            ),
            child: widget.description,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: StylizedRaisedButton(
                text: context.msg.onboarding.permission.button.iUnderstand,
                onPressed: controller.ask,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
