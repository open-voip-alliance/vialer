import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/app/pages/main/settings/availability/ringing_device/widget.dart';
import 'package:vialer/domain/calling/voip/destination.dart';

import '../../../../../../../domain/user/settings/call_setting.dart';
import '../../widgets/user_availability_status_builder/cubit.dart';
import '../../widgets/user_availability_status_builder/widget.dart';
import '../cubit.dart';
import '../widgets/tile/value.dart';
import '../widgets/tile/widget.dart';
import 'availability_status/widget.dart';
import '../../../../resources/theme.dart';
import '../../../../resources/localizations.dart';

class AvailabilitySwitcher extends StatelessWidget {
  const AvailabilitySwitcher({super.key});

  void _showSnackBar(BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(_buildSnackBar(context));

  void _hideSnackBar(BuildContext context) =>
      ScaffoldMessenger.of(context).clearSnackBars();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (_, state) {
        return UserAvailabilityStatusBuilder(
          listener: (context, status, isRingingDeviceOffline) =>
              isRingingDeviceOffline
                  ? _showSnackBar(context)
                  : _hideSnackBar(context),
          builder: (context, status, isRingingDeviceOffline) {
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
                      isRingingDeviceOffline: isRingingDeviceOffline,
                    ),
                  ),
                  if (state.availableDestinations.length >= 1)
                    RingingDevice(
                      user: state.user,
                      destinations: state.availableDestinations,
                      onDestinationChanged: (destination) async =>
                          defaultOnSettingChanged(
                        context,
                        CallSetting.destination,
                        destination.identifier,
                      ),
                      enabled: state.shouldAllowRemoteSettings,
                      userAvailabilityStatus: status,
                      isRingingDeviceOffline: isRingingDeviceOffline,
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

SnackBar _buildSnackBar(BuildContext context) {
  return SnackBar(
    content: Row(
      children: [
        FaIcon(
          FontAwesomeIcons.triangleExclamation,
          color: context.brand.theme.colors.userAvailabilityBusyAccent,
        ),
        SizedBox(
          width: 20,
        ),
        Flexible(
          child: Text(
            context.msg.main.colleagues.status.selectedDeviceOffline,
            style: TextStyle(
              color: context.brand.theme.colors.userAvailabilityBusyAccent,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: context.brand.theme.colors.userAvailabilityBusy,
    duration: Duration(days: 365),
  );
}
