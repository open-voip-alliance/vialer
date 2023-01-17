import 'package:flutter/material.dart';

import '../widgets/colltact_list/widget.dart';
import 'widgets/details/widget.dart';

class ColltactsPage extends StatelessWidget {
  final double bottomLettersPadding;
  final GlobalKey<NavigatorState>? navigatorKey;

  const ColltactsPage({
    Key? key,
    this.navigatorKey,
    this.bottomLettersPadding = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: ColltactList(
          navigatorKey: navigatorKey,
          bottomLettersPadding: bottomLettersPadding,
          detailsBuilder: (_, colltact) =>
              ColltactPageDetails(colltact: colltact),
        ),
      ),
    );
  }
}