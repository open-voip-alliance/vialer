import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/colltacts/get_contact_sort.dart';
import '../../../../../domain/colltacts/get_contacts.dart';
import '../../../../../domain/onboarding/request_permission.dart';
import '../../../../../domain/user/get_permission_status.dart';
import '../../../../../domain/user/permissions/permission.dart';
import '../../../../../domain/user/permissions/permission_status.dart';
import '../../../../../domain/user/settings/open_settings.dart';
import 'state.dart';

export 'state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  final _getContacts = GetContactsUseCase();
  final _getPermissionStatus = GetPermissionStatusUseCase();
  final _requestPermission = RequestPermissionUseCase();
  final _openAppSettings = OpenSettingsAppUseCase();
  final _getContactSort = GetContactSortUseCase();

  ContactsCubit() : super(LoadingContacts()) {
    _checkContactsPermission();
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
    if (state is! ContactsLoaded) {
      emit(LoadingContacts());
    }

    emit(
      ContactsLoaded(
        await _getContacts(),
        await _getContactSort(),
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
