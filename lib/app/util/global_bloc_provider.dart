import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/app/pages/main/colltacts/contacts/cubit.dart';
import 'package:vialer/app/pages/main/colltacts/cubit.dart';

import '../main.dart';
import '../pages/main/business_availability/temporary_redirect/cubit.dart';
import '../pages/main/colltacts/colleagues/cubit.dart';
import '../pages/main/colltacts/shared_contacts/cubit.dart';
import '../pages/main/page.dart';
import '../pages/main/widgets/caller/cubit.dart';
import '../pages/main/widgets/caller/widget.dart';
import '../widgets/connectivity_checker/widget.dart';
import '../widgets/missed_call_notification_listener/widget.dart';
import '../widgets/nested_children.dart';

/// This is the place to register all cubits that are used throughout the app
/// and must only be instantiated once.
class GlobalBlocProvider extends StatelessWidget {
  const GlobalBlocProvider({
    required this.navigatorKey,
    required this.child,
    super.key,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiWidgetParent(
      [
        (child) => Caller.create(
              navigatorKey: navigatorKey,
              child: child,
            ),
        (child) => ConnectivityChecker.create(child: child),
        (child) => MissedCallNotificationPressedListener(
              onMissedCallNotificationPressed: () =>
                  App.navigateTo(MainPageTab.recents),
              child: child,
            ),
        (child) => BlocProvider<TemporaryRedirectCubit>(
              create: (_) => TemporaryRedirectCubit(),
              child: child,
            ),

        /// Using a Builder because the MultiWidgetParent stacks
        /// its children from top to bottom, so the below Provider
        /// can have the needed context with the CallerCubit.
        (child) => Builder(
              builder: (context) {
                return BlocProvider<ColleaguesCubit>(
                  create: (_) => ColleaguesCubit(
                    context.watch<CallerCubit>(),
                  ),
                  child: child,
                );
              },
            ),
        (child) => Builder(
              builder: (context) {
                return BlocProvider<SharedContactsCubit>(
                  create: (_) => SharedContactsCubit(
                    context.watch<CallerCubit>(),
                  ),
                  child: child,
                );
              },
            ),
        (child) => Builder(
              builder: (context) {
                return BlocProvider<ContactsCubit>(
                  create: (_) => ContactsCubit(context.watch<CallerCubit>()),
                  child: child,
                );
              },
            ),
        (child) => Builder(
              builder: (context) {
                return BlocProvider<ColltactsTabsCubit>(
                  create: (_) => ColltactsTabsCubit(
                    context.watch<ContactsCubit>(),
                    context.watch<ColleaguesCubit>(),
                    context.watch<SharedContactsCubit>(),
                  ),
                  child: child,
                );
              },
            ),
      ],
      child,
    );
  }
}
