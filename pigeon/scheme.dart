import 'package:pigeon/pigeon.dart';

enum OrderBy {
  givenName,
  familyName,
}

class ContactSort {
  OrderBy? orderBy;
}

@HostApi()
// ignore:one_member_abstracts
abstract class ContactSortHostApi {
  ContactSort getSorting();
}
