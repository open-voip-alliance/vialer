import 'dart:async';
import 'dart:io';

import '../../app/util/pigeon.dart';
import '../use_case.dart';

class GetContactSortUseCase extends UseCase {
  Future<ContactSort> call() async {
    if (Platform.isIOS) {
      return await ContactSortHostApi().getSorting();
    } else {
      return ContactSort()..orderBy = OrderBy.givenName;
    }
  }
}
