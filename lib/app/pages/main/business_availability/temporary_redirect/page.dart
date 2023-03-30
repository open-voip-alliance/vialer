import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../resources/localizations.dart';
import '../../widgets/full_screen_page.dart';
import 'cubit.dart';
import 'picker.dart';

class TemporaryRedirectPickerPage extends StatelessWidget {
  const TemporaryRedirectPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TemporaryRedirectCubit, TemporaryRedirectState>(
      builder: (context, state) {
        final cubit = context.watch<TemporaryRedirectCubit>();

        return FullScreenPage(
          title: context.msg.main.temporaryRedirect.title,
          body: TemporaryRedirectPicker(
            activeRedirect: state is Active ? state.redirect : null,
            availableDestinations: state.availableRedirectDestinations,
            onStart: (destination, until) => context.popAfter(
              cubit.startOrUpdateCurrentTemporaryRedirect(destination, until),
            ),
            onStop: state is Active
                ? () => context.popAfter(cubit.stopTemporaryRedirect())
                : null,
            onCancel: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  static MaterialPageRoute<void> route() => MaterialPageRoute(
        builder: (_) => const TemporaryRedirectPickerPage(),
      );
}

extension on BuildContext {
  Future<void> popAfter(Future<void> action) async {
    await action;
    Navigator.pop(this);
  }
}
