import 'dart:async';

import '../../dependency_locator.dart';
import '../entities/call_with_contact.dart';
import '../entities/contact.dart';
import '../entities/exceptions/no_permission.dart';
import '../repositories/recent_call.dart';
import '../use_case.dart';
import 'get_contacts.dart';
import 'get_user.dart';

class GetRecentCallsUseCase extends UseCase {
  final _recentCallRepository = dependencyLocator<RecentCallRepository>();

  final _getUser = GetUserUseCase();
  final _getContacts = GetContactsUseCase();

  Future<List<CallWithContact>> call({required int page}) async {
    final user = await _getUser(latest: false);

    Iterable<Contact> contacts;
    try {
      contacts = await _getContacts();
    } on NoPermissionException {
      contacts = [];
    }

    return _recentCallRepository.getRecentCalls(
      page: page,
      outgoingNumber: user!.outgoingCli!,
      contacts: contacts,
    );
  }
}
