import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:timeago/timeago.dart' as timeago;

import 'messages.i18n.dart';
import 'messages_nl.i18n.dart';

class VialerLocalizations {
  final Messages msg;

  VialerLocalizations(this.locale) : msg = _messagesFromLocale(locale) {
    timeago.setLocaleMessages('nl_short', timeago.NlShortMessages());
  }

  final Locale locale;

  static VialerLocalizations of(BuildContext context) {
    return Localizations.of<VialerLocalizations>(context, VialerLocalizations);
  }

  static const delegate = _VialerLocalizationsDelegate();
}

extension LocalizationsContext on BuildContext {
  Messages get msg => VialerLocalizations.of(this).msg;
}

class _VialerLocalizationsDelegate
    extends LocalizationsDelegate<VialerLocalizations> {
  const _VialerLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'nl'].contains(locale.languageCode);

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
      return Messages();
    case 'nl':
      return Messages_nl();
    default:
      throw UnsupportedError('Unsupported locale');
  }
}
