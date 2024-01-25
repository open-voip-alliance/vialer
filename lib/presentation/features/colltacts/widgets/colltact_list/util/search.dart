import 'package:vialer/presentation/util/contact.dart';
import 'package:vialer/presentation/util/extensions.dart';

import '../../../../../../../data/models/colltacts/colltact.dart';

extension ColltactSearch on Colltact {
  bool matchesSearchTerm(String term) => switch (this) {
        ColltactContact colltact => colltact.matchesSearchTerm(term),
        ColltactSharedContact colltact => colltact.matchesSearchTerm(term),
        ColltactColleague colltact => colltact.matchesSearchTerm(term),
      };
}

extension on ColltactContact {
  bool matchesSearchTerm(String term) {
    if (contact.displayName.toLowerCase().contains(term)) return true;
    if (contact.company?.toLowerCase().contains(term) ?? false) return true;

    if (contact.emails.any(
      (email) => email.value.toLowerCase().contains(term),
    )) {
      return true;
    }

    if (contact.phoneNumbers.any(
      (number) => number.value.toLowerCase().replaceAll(' ', '').contains(
            term.formatForPhoneNumberQuery(),
          ),
    )) {
      return true;
    }

    return false;
  }
}

extension on ColltactSharedContact {
  bool matchesSearchTerm(String term) {
    if (contact.displayName.toLowerCase().contains(term)) return true;
    if (contact.companyName?.toLowerCase().contains(term) ?? false) return true;

    for (final number in contact.phoneNumbers) {
      if (number.phoneNumberFlat
          .toLowerCase()
          .contains(term.formatForPhoneNumberQuery())) {
        return true;
      }
    }

    return false;
  }
}

extension on ColltactColleague {
  bool matchesSearchTerm(String term) {
    if (colleague.name.toLowerCase().contains(term)) return true;

    if ((colleague.number ?? '').toLowerCase().replaceAll(' ', '').contains(
          term.formatForPhoneNumberQuery(),
        )) {
      return true;
    }

    return false;
  }
}
