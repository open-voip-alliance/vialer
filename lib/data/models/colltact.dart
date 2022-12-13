import 'package:freezed_annotation/freezed_annotation.dart';

import '../../app/util/contact.dart';
import '../../domain/colltacts/contact.dart';
import '../../domain/user_availability/colleagues/colleague.dart';

part 'colltact.freezed.dart';

/// Wraps a colleague or contact in a single object as they are often used
/// in very similar situations and for a similar purpose.
@freezed
class Colltact with _$Colltact {
  String get name => when(
        colleague: (colleague) => colleague.name,
        contact: (contact) => contact.displayName,
      );

  const Colltact._();
  const factory Colltact.colleague(Colleague colleague) = ColltactColleague;
  const factory Colltact.contact(Contact contact) = ColltactContact;
}
