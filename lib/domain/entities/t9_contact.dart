import 'package:freezed_annotation/freezed_annotation.dart';

import 'contact.dart';
import 'item.dart';

part 't9_contact.freezed.dart';

@freezed
class T9Contact with _$T9Contact {
  const factory T9Contact({
    required Contact contact,
    required Item relevantPhoneNumber,
  }) = _T9Contact;
}
