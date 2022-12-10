import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit.dart';

//TODO: This is a temporary widget, to ensure that the cubit is started when
// the app is launched. This can be removed when the colleagues page exists
// if it is built when the app launches.
class ColleagueRefresher extends StatefulWidget {
  final Widget child;

  ColleagueRefresher._(this.child);

  static Widget create({
    required Widget child,
  }) {
    return BlocProvider<ColleagueCubit>(
      create: (_) => ColleagueCubit(),
      child: ColleagueRefresher._(child),
    );
  }

  @override
  State<StatefulWidget> createState() => _ColleagueRefresherState();
}

class _ColleagueRefresherState extends State<ColleagueRefresher> {
  @override
  Widget build(BuildContext context) {
    // Make sure the cubit is created and running.
    context.read<ColleagueCubit>();
    return widget.child;
  }
}
