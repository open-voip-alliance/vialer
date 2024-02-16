import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/presentation/shared/controllers/user_availability_status_builder/cubit.dart';

import '../../../../../data/models/relations/user_availability_status.dart';

typedef UserAvailabilityStatusBuild = Widget Function(
  BuildContext context,
  UserAvailabilityStatus status,
  bool isCurrentRingingDeviceOffline,
);

typedef UserAvailabilityStatusListener = void Function(
  BuildContext context,
  UserAvailabilityStatus status,
  bool isCurrentRingingDeviceOffline,
);

class UserAvailabilityStatusBuilder extends StatelessWidget {
  const UserAvailabilityStatusBuilder({
    Key? key,
    required this.builder,
    this.listener,
  }) : super(key: key);

  final UserAvailabilityStatusBuild builder;
  final UserAvailabilityStatusListener? listener;

  @override
  Widget build(BuildContext context) {
    final listener = this.listener;

    return BlocConsumer<UserAvailabilityStatusCubit,
        UserAvailabilityStatusState>(
      listener: (context, state) => listener != null
          ? listener(
              context,
              state.status,
              state.isRingingDeviceOffline,
            )
          : null,
      builder: (context, state) => builder(
        context,
        state.status,
        state.isRingingDeviceOffline,
      ),
    );
  }
}
