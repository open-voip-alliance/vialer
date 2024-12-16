import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/presentation/features/colltacts/controllers/contacts/cubit.dart';

import '../features/business_availability/controllers/temporary_redirect/cubit.dart';
import '../features/colltacts/controllers/shared_contacts/cubit.dart';
import '../features/main_page.dart';
import '../features/onboarding/controllers/mobile_number/country_field/cubit.dart';
import '../main.dart';
import '../shared/controllers/caller/cubit.dart';
import '../shared/widgets/caller/widget.dart';
import '../shared/widgets/connectivity_checker/widget.dart';
import '../shared/widgets/missed_call_notification_listener/widget.dart';
import '../shared/widgets/nested_children.dart';

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
              builder: (context) => BlocProvider<CountriesCubit>(
                create: (_) => CountriesCubit(),
                child: child,
              ),
            ),
      ],
      child,
    );
  }
}
