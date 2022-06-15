import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/setting.dart';
import '../../../resources/localizations.dart';
import '../settings/cubit.dart';
import '../settings/widgets/tile.dart';
import '../settings/widgets/tile_category.dart';
import '../widgets/header.dart';

class TelephonyPage extends StatelessWidget {
  const TelephonyPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16,
          ),
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              final settings = state.settings;
              final showDnd = state.showDnd;
              final isVoipAllowed = state.isVoipAllowed;
              final availabilityTile = state.systemUser != null
                  ? SettingTile.availability(
                      settings.get<AvailabilitySetting>(),
                      systemUser: state.systemUser!,
                    )
                  : null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Header(context.msg.main.telephony.title),
                  ),
                  if (!state.isLoading)
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(top: 8),
                        children: [
                          SettingTileCategory.accountInfo(
                            children: [
                              SettingTile.mobileNumber(
                                setting: settings.get<MobileNumberSetting>(),
                                isVoipAllowed: isVoipAllowed,
                              ),
                              SettingTile.associatedNumber(
                                settings.get<BusinessNumberSetting>(),
                              ),
                              if (state.systemUser != null)
                                SettingTile.username(
                                  state.systemUser!,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (showDnd && state.userAvailabilityType != null)
                            SettingTile.dnd(
                              settings.get<DndSetting>(),
                              userAvailabilityType: state.userAvailabilityType!,
                            ),
                          if (availabilityTile != null)
                            availabilityTile,
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
