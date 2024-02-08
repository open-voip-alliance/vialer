import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../data/models/colltacts/colltact.dart';
import '../../../../../../data/models/colltacts/contact.dart';
import '../../../../../../data/models/user/permissions/permission.dart';
import '../../../../../../data/models/user/permissions/permission_status.dart';
import '../../../../../../domain/usecases/colltacts/get_contact_sort.dart';
import '../../../../../../domain/usecases/colltacts/get_contacts.dart';
import '../../../../../../domain/usecases/onboarding/request_permission.dart';
import '../../../../../../domain/usecases/user/get_permission_status.dart';
import '../../../../../../domain/usecases/user/settings/open_settings.dart';
import '../../../../shared/controllers/caller/cubit.dart';
import 'state.dart';

export 'state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit(this._caller) : super(const LoadingContacts()) {
    unawaited(_checkContactsPermission());
  }

  final _getContacts = GetContactsUseCase();
  final _getPermissionStatus = GetPermissionStatusUseCase();
  final _requestPermission = RequestPermissionUseCase();
  final _openAppSettings = OpenSettingsAppUseCase();
  final _getContactSort = GetContactSortUseCase();

  final CallerCubit _caller;

  Future<void> call(String destination) =>
      _caller.call(destination, origin: CallOrigin.contacts);

  Future<void> _checkContactsPermission() async {
    final status = await _getPermissionStatus(permission: Permission.contacts);

    await _loadContacts(status);
  }

  Future<void> _loadContacts(PermissionStatus status) async {
    if (state is! ContactsLoaded) {
      emit(const ContactsState.loading());
    }

    final contacts =
        status == PermissionStatus.granted ? await _getContacts() : <Contact>[];

    emit(
      ContactsState.loaded(
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

  void openAppSettings() => unawaited(_openAppSettings());

  Colltact refreshColltactContact(Colltact colltact) {
    if (state is ContactsLoaded && colltact is ColltactContact) {
      final contact = (state as ContactsLoaded).contacts.firstWhereOrNull(
            (contact) =>
                contact.identifier ==
                (colltact as ColltactContact).contact.identifier,
          );
      if (contact != null) colltact = Colltact.contact(contact);
    }
    return colltact;
  }
}
