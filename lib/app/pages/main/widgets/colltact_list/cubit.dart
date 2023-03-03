import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/colltacts/contact.dart';
import '../../../../../domain/colltacts/get_contact_sort.dart';
import '../../../../../domain/colltacts/get_contacts.dart';
import '../../../../../domain/onboarding/request_permission.dart';
import '../../../../../domain/user/get_permission_status.dart';
import '../../../../../domain/user/permissions/permission.dart';
import '../../../../../domain/user/permissions/permission_status.dart';
import '../../../../../domain/user/settings/open_settings.dart';
import '../caller/cubit.dart';
import 'state.dart';

export 'state.dart';

class ContactsCubit extends Cubit<ContactState> {
  final _getContacts = GetContactsUseCase();
  final _getPermissionStatus = GetPermissionStatusUseCase();
  final _requestPermission = RequestPermissionUseCase();
  final _openAppSettings = OpenSettingsAppUseCase();
  final _getContactSort = GetContactSortUseCase();

  final CallerCubit _caller;

  ContactsCubit(this._caller) : super(const LoadingContacts()) {
    _checkContactsPermission();
  }

  Future<void> call(String destination) =>
      _caller.call(destination, origin: CallOrigin.contacts);

  Future<void> _checkContactsPermission() async {
    final status = await _getPermissionStatus(permission: Permission.contacts);

    await _loadContacts(status);
  }

  Future<void> _loadContacts(PermissionStatus status) async {
    if (state is! ContactsLoaded) {
      emit(const ContactState.loading());
    }

    final contacts =
        status == PermissionStatus.granted ? await _getContacts() : <Contact>[];

    emit(
      ContactState.loaded(
        contacts: contacts,
        contactSort: await _getContactSort(),
        noContactPermission: status != PermissionStatus.granted,
        dontAskAgain: status == PermissionStatus.permanentlyDenied ||
            (Platform.isIOS && status == PermissionStatus.denied),
      ),
    );
  }

  Future<void> reloadContacts() => _checkContactsPermission();

  Future<void> requestPermission() async {
    final status = await _requestPermission(permission: Permission.contacts);

    await _loadContacts(status);
  }

  void openAppSettings() async {
    await _openAppSettings();
  }
}
