import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'messages.i18n.dart';
import 'messages_de.i18n.dart';
import 'messages_nl.i18n.dart';
import 'messages_fr.i18n.dart';

class VialerLocalizations {
  VialerLocalizations(this.locale) : msg = _messagesFromLocale(locale);
  final Messages msg;

  final Locale locale;

  static VialerLocalizations of(BuildContext context) {
    return Localizations.of<VialerLocalizations>(context, VialerLocalizations)!;
  }

  static const delegate = _VialerLocalizationsDelegate();

  static const locales = ['en', 'nl', 'de', 'fr'];
}

extension LocalizationsContext on BuildContext {
  Messages get msg => VialerLocalizations.of(this).msg;

  bool get isEnglish =>
      VialerLocalizations.of(this).locale.languageCode == 'en';

  bool get isDutch => VialerLocalizations.of(this).locale.languageCode == 'nl';

  bool get isGerman => VialerLocalizations.of(this).locale.languageCode == 'de';

  bool get isFrench => VialerLocalizations.of(this).locale.languageCode == 'fr';
}

class _VialerLocalizationsDelegate
    extends LocalizationsDelegate<VialerLocalizations> {
  const _VialerLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      VialerLocalizations.locales.contains(locale.languageCode);

  @override
  Future<VialerLocalizations> load(Locale locale) {
    return SynchronousFuture<VialerLocalizations>(VialerLocalizations(locale));
  }

  @override
  bool shouldReload(_VialerLocalizationsDelegate old) => false;
}

Messages _messagesFromLocale(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return const Messages();
    case 'nl':
      return const MessagesNl();
    case 'de':
      return const MessagesDe();
    case 'fr':
      return const MessagesFr();
    default:
      throw UnsupportedError('Unsupported locale');
  }
}
