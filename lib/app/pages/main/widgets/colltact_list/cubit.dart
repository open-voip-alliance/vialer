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
import '../../../../../domain/user_availability/colleagues/get_colleagues.dart';
import 'state.dart';

export 'state.dart';

class ColltactsCubit extends Cubit<ColltactsState> {
  final _getContacts = GetContactsUseCase();
  final _getColleagues = GetColleagues();
  final _getPermissionStatus = GetPermissionStatusUseCase();
  final _requestPermission = RequestPermissionUseCase();
  final _openAppSettings = OpenSettingsAppUseCase();
  final _getContactSort = GetContactSortUseCase();

  ColltactsCubit() : super(LoadingColltacts()) {
    _checkContactsPermission();
    loadColleagues();
  }

  Future<void> _checkContactsPermission() async {
    final status = await _getPermissionStatus(permission: Permission.contacts);

    await _loadContactsIfAllowed(status);
  }

  Future<void> _loadContactsIfAllowed(PermissionStatus status) async {
    if (status == PermissionStatus.granted) {
      await _loadContacts();
    } else {
      emit(
        NoPermission(
          dontAskAgain: status == PermissionStatus.permanentlyDenied ||
              (Platform.isIOS && status == PermissionStatus.denied),
        ),
      );
    }
  }

  Future<void> _loadContacts() async {
    if (state is! ColltactsLoaded) {
      emit(LoadingColltacts());
    }

    final contacts = await _getContacts();
    final colltacts = contacts.map(Colltact.contact).toList();

    emit(
      ColltactsLoaded(
        colltacts,
        await _getContactSort(),
      ),
    );
  }

  Future<void> loadColleagues() async {
    if (state is! ColltactsLoaded) {
      emit(LoadingColltacts());
    }

    final colleagues = await _getColleagues();
    final colltacts = colleagues.map(Colltact.colleague).toList();

    emit(
      ColltactsLoaded(
        colltacts,
        null,
      ),
    );
  }

  Future<void> reloadContacts() async => await _checkContactsPermission();

  Future<void> requestPermission() async {
    final status = await _requestPermission(permission: Permission.contacts);

    await _loadContactsIfAllowed(status);
  }

  void openAppSettings() async {
    await _openAppSettings();
  }
}
