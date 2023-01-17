import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/models/colltact.dart';
import '../../../../../domain/colltacts/contact.dart';
import '../../../../../domain/colltacts/get_contact_sort.dart';
import '../../../../../domain/colltacts/get_contacts.dart';
import '../../../../../domain/metrics/track_colleague_tab_selected.dart';
import '../../../../../domain/onboarding/request_permission.dart';
import '../../../../../domain/user/get_logged_in_user.dart';
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
  final _getUser = GetLoggedInUserUseCase();
  final _trackColleagueTabSelected = TrackColleagueTabSelectedUseCase();

  List<Colleague> get _colleagues => _colleaguesCubit.state.when(
        loading: () => [],
        loaded: (colleagues) => colleagues,
      );

  bool get shouldShowColleagues =>
      _getUser().permissions.canViewColleagues && _colleagues.isNotEmpty;

  final ColleagueCubit _colleaguesCubit;

  ColltactsCubit(this._colleaguesCubit) : super(const LoadingColltacts()) {
    _checkColltactsPermission();

    // Check the initial state as there may already be some colleagues loaded.
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
    final colltacts = colleagues.mergeColltacts(state.colltacts.contacts);

    emit(state.copyWith(colltacts: colltacts));

    // If we get a colleagues update before the contacts are loaded we might
    // get an empty list, so we'll just load them here if we don't have any.
    if (state.colltacts.contacts.isEmpty) {
      _checkColltactsPermission();
    }
  }

  Future<void> _checkColltactsPermission() async {
    final status = await _getPermissionStatus(permission: Permission.contacts);

    await _loadColltacts(status);
  }

  Future<void> _loadColltacts(PermissionStatus status) async {
    final state = this.state;

    if (state is! ColltactsLoaded) {
      emit(const LoadingColltacts());
    }

    emit(
      ColltactsLoaded(
        colltacts: status == PermissionStatus.granted
            ? _colleagues.mergeColltacts(await _getContacts())
            : _colleagues.map(Colltact.colleague),
        contactSort: await _getContactSort(),
        noContactPermission: status != PermissionStatus.granted,
        dontAskAgain: status == PermissionStatus.permanentlyDenied ||
            (Platform.isIOS && status == PermissionStatus.denied),
      ),
    );
  }

  Future<void> reloadColltacts() async => await _checkColltactsPermission();

  Future<void> requestPermission() async {
    final status = await _requestPermission(permission: Permission.contacts);

    await _loadColltacts(status);
  }

  void openAppSettings() async {
    await _openAppSettings();
  }

  void trackColleaguesTabSelected() => _trackColleagueTabSelected();
}

extension on List<Colleague> {
  List<Colltact> mergeColltacts(Iterable<Contact> contacts) =>
      map(Colltact.colleague).toList()..addAll(contacts.map(Colltact.contact));
}

extension on Iterable<Colltact> {
  Iterable<Contact> get contacts => whereType<Contact>();
}
