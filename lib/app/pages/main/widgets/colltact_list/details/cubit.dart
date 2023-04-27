import 'dart:async';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../../data/models/colltact.dart';
import '../../../../../../domain/onboarding/request_permission.dart';
import '../../../../../../domain/user/permissions/permission.dart';
import '../../../../../../domain/user/permissions/permission_status.dart';
import '../../../widgets/caller.dart';
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
    if (colltact is ColltactContact) {
      final status = await _requestPermission(permission: Permission.contacts);

      if (status == PermissionStatus.granted) {
        final contact = colltact.contact;

        if (Platform.isAndroid) {
          final intent = AndroidIntent(
            action: 'android.intent.action.EDIT',
            data:
                'content://com.android.contacts/contacts/${contact.identifier}',
          );

          await intent.launch();
        } else {
          try {
            await ContactsService.openExistingContact(
              Contact()..identifier = contact.identifier,
            );
          } on FormOperationException {
            // Thrown when native edit is cancelled
          }
        }
      }
    }
  }
}
