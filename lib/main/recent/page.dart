import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/header.dart';
import 'widgets/item.dart';
import 'bloc.dart';

class RecentPage extends StatefulWidget {
  RecentPage._();

  static Widget create() {
    return BlocProvider<RecentBloc>(
      create: (context) => RecentBloc(),
      child: RecentPage._(),
    );
  }

  @override
  State<StatefulWidget> createState() => _RecentPageState();
}

class _RecentPageState extends State<RecentPage> {
  @override
  Widget build(BuildContext context) {
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
                child: Header('Recent calls'),
              ),
              Expanded(
                child: BlocBuilder<RecentBloc, RecentState>(
                  builder: (context, state) {
                    if (state is RecentsLoaded) {
                      return ListView(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        children: state.items
                            .map((item) => RecentCallItem(item: item))
                            .toList(),
                      );
                    }

                    return Container();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
