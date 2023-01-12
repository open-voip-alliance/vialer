import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/models/colltact.dart';
import '../../../../../domain/colltacts/get_contact_sort.dart';
import '../../../../../domain/colltacts/get_contacts.dart';
import '../../../../../domain/onboarding/request_permission.dart';
import '../../../../../domain/user/get_permission_status.dart';
import '../../../../../domain/user/permissions/permission.dart';
import '../../../../../domain/user/permissions/permission_status.dart';
import '../../../../../domain/user/settings/open_settings.dart';
import '../../../../../domain/user_availability/colleagues/receive_colleague_availability.dart';
import 'state.dart';

export 'state.dart';

class ColltactsCubit extends Cubit<ColltactsState> {
  final _getContacts = GetContactsUseCase();
  final _getPermissionStatus = GetPermissionStatusUseCase();
  final _requestPermission = RequestPermissionUseCase();
  final _openAppSettings = OpenSettingsAppUseCase();
  final _getContactSort = GetContactSortUseCase();

  late final _receiveColleagueAvailability = ReceiveColleagueAvailability();

  bool shouldShowColleagues = false;

  ColltactsCubit() : super(LoadingColltacts()) {
    _checkColltactsPermission();
  }

  Future<void> _checkColltactsPermission() async {
    final status = await _getPermissionStatus(permission: Permission.contacts);

    await _loadColltactsIfAllowed(status);
  }

  Future<void> _loadColltactsIfAllowed(PermissionStatus status) async {
    if (status == PermissionStatus.granted) {
      await _loadColltacts();
    } else {
      emit(
        NoPermission(
          dontAskAgain: status == PermissionStatus.permanentlyDenied ||
              (Platform.isIOS && status == PermissionStatus.denied),
        ),
      );
    }
  }

  Future<void> _loadColltacts() async {
    if (state is! ColltactsLoaded) {
      emit(LoadingColltacts());
    }

    final contacts = await _getContacts();
    final contactSort = await _getContactSort();

    _receiveColleagueAvailability().listen((colleagues) {
      if (colleagues.isNotEmpty) {
        shouldShowColleagues = true;
      }

      var colltacts = colleagues.map(Colltact.colleague).toList();
      colltacts.addAll(contacts.map(Colltact.contact).toList());

      emit(
        ColltactsLoaded(
          colltacts,
          contactSort,
        ),
      );
    });
  }

  Future<void> reloadColltacts() async => await _checkColltactsPermission();

  Future<void> requestPermission() async {
    final status = await _requestPermission(permission: Permission.contacts);

    await _loadColltactsIfAllowed(status);
  }

  void openAppSettings() async {
    await _openAppSettings();
  }
}
