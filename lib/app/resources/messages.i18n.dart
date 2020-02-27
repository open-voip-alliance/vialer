// GENERATED FILE, do not edit!
import 'package:i18n/i18n.dart' as i18n;

String get _languageCode => 'en';
String get _localeName => 'en';

String _plural(int count, {String zero, String one, String two, String few, String many, String other}) =>
	i18n.plural(count, _languageCode, zero:zero, one:one, two:two, few:few, many:many, other:other);
String _ordinal(int count, {String zero, String one, String two, String few, String many, String other}) =>
	i18n.ordinal(count, _languageCode, zero:zero, one:one, two:two, few:few, many:many, other:other);
String _cardinal(int count, {String zero, String one, String two, String few, String many, String other}) =>
	i18n.cardinal(count, _languageCode, zero:zero, one:one, two:two, few:few, many:many, other:other);

class Messages {
	const Messages();
	GenericMessages get generic => GenericMessages(this);
	MainMessages get main => MainMessages(this);
	OnboardingMessages get onboarding => OnboardingMessages(this);
}

class GenericMessages {
	final Messages _parent;
	const GenericMessages(this._parent);
	ButtonGenericMessages get button => ButtonGenericMessages(this);
}

class ButtonGenericMessages {
	final GenericMessages _parent;
	const ButtonGenericMessages(this._parent);
	String get cancel => "Cancel";
}

class MainMessages {
	final Messages _parent;
	const MainMessages(this._parent);
	DialerMainMessages get dialer => DialerMainMessages(this);
	RecentMainMessages get recent => RecentMainMessages(this);
	ContactsMainMessages get contacts => ContactsMainMessages(this);
	SettingsMainMessages get settings => SettingsMainMessages(this);
}

class DialerMainMessages {
	final MainMessages _parent;
	const DialerMainMessages(this._parent);
	String get title => "Keypad";
	MenuDialerMainMessages get menu => MenuDialerMainMessages(this);
	ConfirmDialerMainMessages get confirm => ConfirmDialerMainMessages(this);
}

class MenuDialerMainMessages {
	final DialerMainMessages _parent;
	const MenuDialerMainMessages(this._parent);
	String get title => "Keypad";
}

class ConfirmDialerMainMessages {
	final DialerMainMessages _parent;
	const ConfirmDialerMainMessages(this._parent);
	String get title => "Vialer Lite Call";
	DescriptionConfirmDialerMainMessages get description => DescriptionConfirmDialerMainMessages(this);
	ButtonConfirmDialerMainMessages get button => ButtonConfirmDialerMainMessages(this);
}

class DescriptionConfirmDialerMainMessages {
	final ConfirmDialerMainMessages _parent;
	const DescriptionConfirmDialerMainMessages(this._parent);
	String get origin => "Dialing from your business number";
	String get main => "Vialer Lite will route your call through,\nkeeping your personal number private";
	String get action => "Tap the “Call” button to dial:";
}

class ButtonConfirmDialerMainMessages {
	final ConfirmDialerMainMessages _parent;
	const ButtonConfirmDialerMainMessages(this._parent);
	String call(String number) => "Call $number";
}

class RecentMainMessages {
	final MainMessages _parent;
	const RecentMainMessages(this._parent);
	String get title => "Recent calls";
	MenuRecentMainMessages get menu => MenuRecentMainMessages(this);
}

class MenuRecentMainMessages {
	final RecentMainMessages _parent;
	const MenuRecentMainMessages(this._parent);
	String get title => "Recent";
}

class ContactsMainMessages {
	final MainMessages _parent;
	const ContactsMainMessages(this._parent);
	String get title => "Contacts";
	MenuContactsMainMessages get menu => MenuContactsMainMessages(this);
	ListContactsMainMessages get list => ListContactsMainMessages(this);
}

class MenuContactsMainMessages {
	final ContactsMainMessages _parent;
	const MenuContactsMainMessages(this._parent);
	String get title => "Contacts";
}

class ListContactsMainMessages {
	final ContactsMainMessages _parent;
	const ListContactsMainMessages(this._parent);
	ItemListContactsMainMessages get item => ItemListContactsMainMessages(this);
}

class ItemListContactsMainMessages {
	final ListContactsMainMessages _parent;
	const ItemListContactsMainMessages(this._parent);
	String get noNumber => "No number";
	String numbers(int count) => "$count ${_plural(count, one: 'number', many: 'numbers')}";
	String emails(int count) => "$count ${_plural(count, one: 'email', many: 'emails')}";
}

class SettingsMainMessages {
	final MainMessages _parent;
	const SettingsMainMessages(this._parent);
	String get title => "Settings";
	MenuSettingsMainMessages get menu => MenuSettingsMainMessages(this);
}

class MenuSettingsMainMessages {
	final SettingsMainMessages _parent;
	const MenuSettingsMainMessages(this._parent);
	String get title => "Settings";
}

class OnboardingMessages {
	final Messages _parent;
	const OnboardingMessages(this._parent);
	ButtonOnboardingMessages get button => ButtonOnboardingMessages(this);
	InitialOnboardingMessages get initial => InitialOnboardingMessages(this);
	LoginOnboardingMessages get login => LoginOnboardingMessages(this);
	PermissionOnboardingMessages get permission => PermissionOnboardingMessages(this);
}

class ButtonOnboardingMessages {
	final OnboardingMessages _parent;
	const ButtonOnboardingMessages(this._parent);
	String get login => "Login";
}

class InitialOnboardingMessages {
	final OnboardingMessages _parent;
	const InitialOnboardingMessages(this._parent);
	String get title => "Private\nbusiness calls";
	String get description => "Private calling with your business\nnumber just got an upgrade";
}

class LoginOnboardingMessages {
	final OnboardingMessages _parent;
	const LoginOnboardingMessages(this._parent);
	PlaceholderLoginOnboardingMessages get placeholder => PlaceholderLoginOnboardingMessages(this);
	ButtonLoginOnboardingMessages get button => ButtonLoginOnboardingMessages(this);
}

class PlaceholderLoginOnboardingMessages {
	final LoginOnboardingMessages _parent;
	const PlaceholderLoginOnboardingMessages(this._parent);
	String get username => "Username";
	String get password => "Password";
}

class ButtonLoginOnboardingMessages {
	final LoginOnboardingMessages _parent;
	const ButtonLoginOnboardingMessages(this._parent);
	String get forgotPassword => "Forgot password";
}

class PermissionOnboardingMessages {
	final OnboardingMessages _parent;
	const PermissionOnboardingMessages(this._parent);
	ButtonPermissionOnboardingMessages get button => ButtonPermissionOnboardingMessages(this);
	CallPermissionOnboardingMessages get call => CallPermissionOnboardingMessages(this);
	ContactsPermissionOnboardingMessages get contacts => ContactsPermissionOnboardingMessages(this);
}

class ButtonPermissionOnboardingMessages {
	final PermissionOnboardingMessages _parent;
	const ButtonPermissionOnboardingMessages(this._parent);
	String get iUnderstand => "I understand";
}

class CallPermissionOnboardingMessages {
	final PermissionOnboardingMessages _parent;
	const CallPermissionOnboardingMessages(this._parent);
	String get title => "Call permission";
	String get description => "This permission is required to make calls seamlessly from the app using the default call app.";
}

class ContactsPermissionOnboardingMessages {
	final PermissionOnboardingMessages _parent;
	const ContactsPermissionOnboardingMessages(this._parent);
	String get title => "Contacts";
	String get description => "This permission is required to view contacts in-app.";
}

