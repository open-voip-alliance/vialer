import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/contacts/contact.dart';
import '../../domain/user_availability/colleagues/colleague.dart';

part 'colltact.freezed.dart';

/// Wraps a colleague or contact in a single object as they are often used
/// in very similar situations and for a similar purpose.
@freezed
class Colltact with _$Colltact {
  const factory Colltact.colleague(Colleague colleague) = Colleague;
  const factory Colltact.contact(Contact contact) = Contact;
}
