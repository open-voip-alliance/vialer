import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../../../presentation/util/pigeon.dart';

@singleton
class ClipBoardRepository {
  Future<String?> getClipboardText() =>
      Clipboard.getData(Clipboard.kTextPlain).then((data) => data?.text);

  Future<bool?> hasNumberInClipboard() => NativeClipboard().hasPhoneNumber();
}
