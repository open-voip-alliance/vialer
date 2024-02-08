import 'dart:async';
import 'dart:io';

import '../../../presentation/util/pigeon.dart';
import '../use_case.dart';

final ContactSort defaultContactSort = ContactSort()
  ..orderBy = OrderBy.givenName;

class GetContactSortUseCase extends UseCase {
  Future<ContactSort> call() async {
    if (Platform.isIOS) {
      return ContactSortHostApi().getSorting();
    } else {
      return defaultContactSort;
    }
  }
}
