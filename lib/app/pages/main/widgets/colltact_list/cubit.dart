import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/models/colltact.dart';
import '../../../../../domain/colltacts/contact.dart';
import '../../../../../domain/colltacts/get_contact_sort.dart';
import '../../../../../domain/colltacts/get_contacts.dart';
import '../../../../../domain/onboarding/request_permission.dart';
import '../../../../../domain/user/get_permission_status.dart';
import '../../../../../domain/user/permissions/permission.dart';
import '../../../../../domain/user/permissions/permission_status.dart';
import '../../../../../domain/user/settings/open_settings.dart';
import '../../../../../domain/user_availability/colleagues/colleague.dart';
import '../../colltacts/colleagues/cubit.dart';
import 'state.dart';

export 'state.dart';

class ColltactsCubit extends Cubit<ColltactsState> {
  final _getContacts = GetContactsUseCase();
  final _getPermissionStatus = GetPermissionStatusUseCase();
  final _requestPermission = RequestPermissionUseCase();
  final _openAppSettings = OpenSettingsAppUseCase();
  final _getContactSort = GetContactSortUseCase();

  List<Colleague> get _colleagues => _colleaguesCubit.state.when(
        loading: () => [],
        loaded: (colleagues) => colleagues,
      );

  bool get shouldShowColleagues => _colleagues.isNotEmpty;

  final ColleagueCubit _colleaguesCubit;

  ColltactsCubit(this._colleaguesCubit) : super(const LoadingColltacts()) {
    _checkColltactsPermission();

    _colleaguesCubit.state.when(
      loading: () => null,
      loaded: _handleColleaguesUpdate,
    );

    _colleaguesCubit.stream.listen(
      (event) => event.when(
        loading: () => null,
        loaded: _handleColleaguesUpdate,
      ),
    );
  }

  void _handleColleaguesUpdate(List<Colleague> colleagues) {
    final state = this.state;

    if (state is! ColltactsLoaded) return;

    // We want to replace all the colleagues but leave the loaded contacts
    // alone.
    final colltacts = colleagues.map(Colltact.colleague).toList()
      ..addAll(
        state.colltacts.whereType<Contact>() as Iterable<Colltact>,
      );

    emit(ColltactsLoaded(colltacts, state.contactSort));
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
    final state = this.state;

    if (state is! ColltactsLoaded) {
      emit(const LoadingColltacts());
    }

    final contacts = await _getContacts();
    final contactSort = await _getContactSort();

    final colltacts = <Colltact>[]
      ..addAll(_colleagues.map(Colltact.colleague))
      ..addAll(contacts.map(Colltact.contact));

    emit(ColltactsLoaded(colltacts, contactSort));
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
