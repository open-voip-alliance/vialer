import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../domain/entities/contact.dart' as domain;
import '../../../../../domain/entities/permission.dart';
import '../../../../../domain/entities/permission_status.dart';
import '../../../../../domain/usecases/onboarding/request_permission.dart';
import '../../widgets/caller.dart';
import 'state.dart';

class ContactDetailsCubit extends Cubit<ContactDetailsState> {
  final _requestPermission = RequestPermissionUseCase();

  final CallerCubit _caller;

  ContactDetailsCubit(this._caller) : super(ContactDetailsState());

  Future<void> call(String destination) =>
      _caller.call(destination, origin: CallOrigin.contacts);

  void mail(String destination) {
    launch('mailto:$destination');
  }

  Future<void> edit(domain.Contact contact) async {
    final status = await _requestPermission(permission: Permission.contacts);

    if (status == PermissionStatus.granted) {
      if (Platform.isAndroid) {
        final intent = AndroidIntent(
          action: 'android.intent.action.EDIT',
          data: 'content://com.android.contacts/contacts/${contact.identifier}',
        );

        await intent.launch();
      } else {
        try {
          final _contact = Contact()..identifier = contact.identifier;
          await ContactsService.openExistingContact(_contact);
        } on FormOperationException {} // Thrown when native edit is cancelled.
      }
    }
  }
}
