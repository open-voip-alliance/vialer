import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../presentation/util/contact.dart';
import '../../../presentation/util/pigeon.dart';
import '../relations/colleagues/colleague.dart';
import 'contact.dart';
import 'shared_contacts/shared_contact.dart';

part 'colltact.freezed.dart';

/// Wraps a colleague, webphone shared contact and phone contact in a single
/// object as they are often used in very similar situations and for a similar
/// purpose.
@freezed
sealed class Colltact with _$Colltact {
  const Colltact._();
  const factory Colltact.colleague(Colleague colleague) = ColltactColleague;
  const factory Colltact.contact(Contact contact) = ColltactContact;
  const factory Colltact.sharedContact(SharedContact contact) =
      ColltactSharedContact;

  String get name => switch (this) {
        ColltactColleague colleague => colleague.colleague.name,
        ColltactContact contact => contact.contact.displayName,
        ColltactSharedContact sharedContact =>
          sharedContact.contact.displayName,
      };

  String Function(ContactSort) get getSortKey => when(
        colleague: (colleague) => (_) => colleague.name.toLowerCase(),
        contact: (contact) {
          return (contactSort) {
            final sortKey = contactSort.orderBy == OrderBy.familyName
                ? contact.familyName
                : contact.givenName ?? contact.displayName;

            return sortKey?.toLowerCase() ?? '';
          };
        },
        sharedContact: (sharedContact) =>
            (_) => sharedContact.displayName.toLowerCase(),
      );
}
