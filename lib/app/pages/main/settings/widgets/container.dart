import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/nested_navigator.dart';
import '../cubit.dart';

/// Wraps the content of the Settings Page with the necessary scaffolding and
/// navigation.
class SettingsPageContainer extends StatelessWidget {
  const SettingsPageContainer({
    required this.scaffoldMessengerKey,
    required this.child,
    super.key,
  });

  final Widget child;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: NestedNavigator(
        routes: {
          'root': (context, _) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      BlocProvider<SettingsCubit>(
                        create: (_) => SettingsCubit(),
                        child: child,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        },
      ),
    );
  }
}
