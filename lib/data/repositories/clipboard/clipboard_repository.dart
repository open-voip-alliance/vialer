import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@singleton
class ClipBoardRepository {
  Future<String?> getClipboardText() =>
      Clipboard.getData(Clipboard.kTextPlain).then((data) => data?.text);
}
