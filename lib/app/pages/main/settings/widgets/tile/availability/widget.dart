import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vialer/app/pages/main/settings/widgets/tile/availability/ringing_device/widget.dart';

import '../../../../../../../domain/user/settings/call_setting.dart';
import '../../../../widgets/user_availability_status_builder/cubit.dart';
import '../../../../widgets/user_availability_status_builder/widget.dart';
import '../../../cubit.dart';
import '../value.dart';
import '../widget.dart';
import 'availability_status/widget.dart';

class AvailabilitySwitcher extends StatelessWidget {
  const AvailabilitySwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (_, state) {
        return UserAvailabilityStatusBuilder(
          builder: (context, status) {
            return SettingTile(
              padding: EdgeInsets.zero,
              mergeSemantics: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AvailabilityStatusPicker(
                      onStatusChanged: (status) async => context
                          .read<UserAvailabilityStatusCubit>()
                          .changeAvailabilityStatus(
                            status,
                            state.availableDestinations,
                          ),
                      user: state.user,
                      enabled: state.shouldAllowRemoteSettings,
                      userAvailabilityStatus: status,
                    ),
                  ),
                  if (state.availableDestinations.length >= 2)
                    RingingDevice(
                      user: state.user,
                      destinations: state.availableDestinations,
                      onDestinationChanged: (destination) async =>
                          defaultOnSettingChanged(
                        context,
                        CallSetting.destination,
                        destination,
                      ),
                      enabled: state.shouldAllowRemoteSettings,
                      userAvailabilityStatus: status,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
