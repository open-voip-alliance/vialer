import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/full_screen_page.dart';
import '../cubit.dart';

typedef MultiChildStateBuilder = List<Widget> Function(SettingsState state);

class SettingsSubPage extends StatelessWidget {
  final SettingsCubit cubit;
  final Widget title;
  final MultiChildStateBuilder children;

  const SettingsSubPage({
    Key? key,
    required this.cubit,
    required this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FullScreenPage(
      title: title,
      body: BlocProvider.value(
        value: cubit,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.only(top: 8),
              children: children(state),
            );
          },
        ),
      ),
    );
  }
}
