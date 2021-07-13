import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String data;
  final EdgeInsets padding;

  const Header(
    this.data, {
    Key? key,
    this.padding = const EdgeInsets.only(bottom: 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        data,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 38,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
