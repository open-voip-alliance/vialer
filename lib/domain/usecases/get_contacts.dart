import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../entities/contact.dart';
import '../repositories/contact.dart';

class GetContactsUseCase extends UseCase<List<Contact>, void> {
  final ContactRepository _contactsRepository;

  GetContactsUseCase(this._contactsRepository);

  @override
  Future<Stream<List<Contact>>> buildUseCaseStream(_) async {
    final controller = StreamController<List<Contact>>();

    controller.add(await _contactsRepository.getContacts());
    unawaited(controller.close());

    return controller.stream;
  }
}
