import '../entities/contact.dart';

// ignore: one_member_abstracts
abstract class ContactRepository {
  Future<List<Contact>> getContacts();
}
