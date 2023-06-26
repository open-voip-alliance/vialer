import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/app/pages/main/widgets/user_availability_status_builder/cubit.dart';

import '../../../../../domain/user_availability/colleagues/colleague.dart';

typedef UserAvailabilityStatusBuild = Widget Function(
  BuildContext context,
  ColleagueAvailabilityStatus status,
);

class UserAvailabilityStatusBuilder extends StatelessWidget {
  const UserAvailabilityStatusBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final UserAvailabilityStatusBuild builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserAvailabilityStatusCubit,
        UserAvailabilityStatusState>(
      builder: (context, state) => builder(context, state.status),
    );
  }
}
