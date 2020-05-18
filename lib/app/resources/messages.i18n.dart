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
	String get ok => "Ok";
	String get cancel => "Cancel";
}

class MainMessages {
	final Messages _parent;
	const MainMessages(this._parent);
	CallThroughMainMessages get callThrough => CallThroughMainMessages(this);
	DialerMainMessages get dialer => DialerMainMessages(this);
	RecentMainMessages get recent => RecentMainMessages(this);
	ContactsMainMessages get contacts => ContactsMainMessages(this);
	SettingsMainMessages get settings => SettingsMainMessages(this);
}

class CallThroughMainMessages {
	final MainMessages _parent;
	const CallThroughMainMessages(this._parent);
	ErrorCallThroughMainMessages get error => ErrorCallThroughMainMessages(this);
}

class ErrorCallThroughMainMessages {
	final CallThroughMainMessages _parent;
	const ErrorCallThroughMainMessages(this._parent);
	String get title => "An error occurred";
	String get unknown => "Unknown error.";
	String get invalidDestination => "Dialed number is invalid.";
}

class DialerMainMessages {
	final MainMessages _parent;
	const DialerMainMessages(this._parent);
	String get title => "Keypad";
	String get permissionDenied => "The call permission is denied, which is required to make seamless calls.";
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
	SnackBarRecentMainMessages get snackBar => SnackBarRecentMainMessages(this);
	ListRecentMainMessages get list => ListRecentMainMessages(this);
}

class MenuRecentMainMessages {
	final RecentMainMessages _parent;
	const MenuRecentMainMessages(this._parent);
	String get title => "Recent";
}

class SnackBarRecentMainMessages {
	final RecentMainMessages _parent;
	const SnackBarRecentMainMessages(this._parent);
	String get copied => "Phone number copied";
}

class ListRecentMainMessages {
	final RecentMainMessages _parent;
	const ListRecentMainMessages(this._parent);
	PopupMenuListRecentMainMessages get popupMenu => PopupMenuListRecentMainMessages(this);
	EmptyListRecentMainMessages get empty => EmptyListRecentMainMessages(this);
}

class PopupMenuListRecentMainMessages {
	final ListRecentMainMessages _parent;
	const PopupMenuListRecentMainMessages(this._parent);
	String get copy => "Copy";
	String get call => "Call";
}

class EmptyListRecentMainMessages {
	final ListRecentMainMessages _parent;
	const EmptyListRecentMainMessages(this._parent);
	String get title => "No recent activity";
	String get description => "There is no recent call activity to show. Once you make or receive a call, it will appear here.";
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
	EmptyListContactsMainMessages get empty => EmptyListContactsMainMessages(this);
	NoPermissionListContactsMainMessages get noPermission => NoPermissionListContactsMainMessages(this);
	ItemListContactsMainMessages get item => ItemListContactsMainMessages(this);
}

class EmptyListContactsMainMessages {
	final ListContactsMainMessages _parent;
	const EmptyListContactsMainMessages(this._parent);
	String get title => "No contacts found";
	String get description => "Vialer was unable to find any contacts in your phone. If you create contacts they will be shown in Vialer.";
}

class NoPermissionListContactsMainMessages {
	final ListContactsMainMessages _parent;
	const NoPermissionListContactsMainMessages(this._parent);
	String get title => "No access to contacts";
	String get description => "Vialer needs permission to retrieve your contacts and display them.";
	String get button => "Give permission";
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
	ListSettingsMainMessages get list => ListSettingsMainMessages(this);
	ButtonsSettingsMainMessages get buttons => ButtonsSettingsMainMessages(this);
	FeedbackSettingsMainMessages get feedback => FeedbackSettingsMainMessages(this);
}

class MenuSettingsMainMessages {
	final SettingsMainMessages _parent;
	const MenuSettingsMainMessages(this._parent);
	String get title => "Settings";
}

class ListSettingsMainMessages {
	final SettingsMainMessages _parent;
	const ListSettingsMainMessages(this._parent);
	DebugListSettingsMainMessages get debug => DebugListSettingsMainMessages(this);
	String get version => "Version";
}

class DebugListSettingsMainMessages {
	final ListSettingsMainMessages _parent;
	const DebugListSettingsMainMessages(this._parent);
	String get title => "Debug";
	String get remoteLogging => "Remote logging";
}

class ButtonsSettingsMainMessages {
	final SettingsMainMessages _parent;
	const ButtonsSettingsMainMessages(this._parent);
	String get sendFeedback => "Send feedback";
	String get logout => "Logout";
}

class FeedbackSettingsMainMessages {
	final SettingsMainMessages _parent;
	const FeedbackSettingsMainMessages(this._parent);
	String get title => "Feedback";
	PlaceholdersFeedbackSettingsMainMessages get placeholders => PlaceholdersFeedbackSettingsMainMessages(this);
	String get snackBar => "Feedback sent";
	ButtonsFeedbackSettingsMainMessages get buttons => ButtonsFeedbackSettingsMainMessages(this);
}

class PlaceholdersFeedbackSettingsMainMessages {
	final FeedbackSettingsMainMessages _parent;
	const PlaceholdersFeedbackSettingsMainMessages(this._parent);
	String get title => "Title";
	String get text => "Enter your feedback here";
}

class ButtonsFeedbackSettingsMainMessages {
	final FeedbackSettingsMainMessages _parent;
	const ButtonsFeedbackSettingsMainMessages(this._parent);
	String get send => "Send feedback";
}

class OnboardingMessages {
	final Messages _parent;
	const OnboardingMessages(this._parent);
	ButtonOnboardingMessages get button => ButtonOnboardingMessages(this);
	InitialOnboardingMessages get initial => InitialOnboardingMessages(this);
	LoginOnboardingMessages get login => LoginOnboardingMessages(this);
	PermissionOnboardingMessages get permission => PermissionOnboardingMessages(this);
	VoicemailOnboardingMessages get voicemail => VoicemailOnboardingMessages(this);
	WelcomeOnboardingMessages get welcome => WelcomeOnboardingMessages(this);
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
	String get title => "Login";
	PlaceholderLoginOnboardingMessages get placeholder => PlaceholderLoginOnboardingMessages(this);
	ButtonLoginOnboardingMessages get button => ButtonLoginOnboardingMessages(this);
	ErrorLoginOnboardingMessages get error => ErrorLoginOnboardingMessages(this);
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

class ErrorLoginOnboardingMessages {
	final LoginOnboardingMessages _parent;
	const ErrorLoginOnboardingMessages(this._parent);
	String get wrongCombination => "Incorrect username & password combination. Check your login details and try again.";
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
	String get title => "Contacts permission";
	String get description => "This permission allows Reborn to display information (contact book & call activity) and to search through your contacts.\n\nThe data will be solely used for display and search purposes.";
}

class VoicemailOnboardingMessages {
	final OnboardingMessages _parent;
	const VoicemailOnboardingMessages(this._parent);
	String get title => "Voicemail";
	String get description => "Please note that if you don't use a personalized voicemail, it may contain your personal number which is then leaked if people call your business number.";
}

class WelcomeOnboardingMessages {
	final OnboardingMessages _parent;
	const WelcomeOnboardingMessages(this._parent);
	String get title => "Welcome";
}

