import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../../../data/models/colltacts/colltact.dart';
import '../../../../../../../data/models/user/permissions/permission.dart';
import '../../../../../../../data/models/user/permissions/permission_status.dart';
import '../../../../../../../domain/usecases/onboarding/request_permission.dart';
import '../../../../../shared/widgets/caller.dart';
import 'state.dart';

class ColltactDetailsCubit extends Cubit<ColltactDetailsState> {
  ColltactDetailsCubit(this._caller) : super(const ColltactDetailsState());
  final _requestPermission = RequestPermissionUseCase();

  final CallerCubit _caller;

  Future<void> call(
    String destination, {
    CallOrigin origin = CallOrigin.contacts,
  }) =>
      _caller.call(destination, origin: origin);

  void mail(String destination) {
    unawaited(launchUrlString('mailto:$destination'));
  }

  Future<void> edit(Colltact colltact) async {
    if (colltact is! ColltactContact) return;

    final status = await _requestPermission(permission: Permission.contacts);

    if (status != PermissionStatus.granted) return;

    final id = colltact.contact.identifier;

    if (id == null) return;

    await FlutterContacts.openExternalEdit(id);
  }
}
