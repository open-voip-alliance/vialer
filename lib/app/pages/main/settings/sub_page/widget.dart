import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/full_screen_page.dart';
import '../cubit.dart';

typedef ChildStateBuilder = Widget Function(SettingsState state);

class SettingsSubPage extends StatelessWidget {
  const SettingsSubPage({
    required this.cubit,
    required this.title,
    required this.child,
    super.key,
  });

  final SettingsCubit cubit;
  final String title;
  final ChildStateBuilder child;

  @override
  Widget build(BuildContext context) {
    return FullScreenPage(
      title: title,
      body: BlocProvider.value(
        value: cubit,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: child(state),
            );
          },
        ),
      ),
    );
  }
}
