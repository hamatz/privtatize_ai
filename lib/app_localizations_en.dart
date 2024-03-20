import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get register_pass_title => 'submit password for app activation';

  @override
  String get register_pass_message => 'welcome!';

  @override
  String get register_pass_info => 'For using this app safely, please submit your password';

  @override
  String get register_pass_text_label => 'password';

  @override
  String get register_pass_button_label => 'Submit';

  @override
  String get validate_pass_title => 'password authentication';

  @override
  String get validate_pass_info => 'please input your app activation password';

  @override
  String get validate_pass_text_label => 'password';

  @override
  String get validate_pass_button_label => 'Login';

  @override
  String get validate_pass_error => 'Password error. Please re-input your password';

  @override
  String get setting_title => 'Settings';

  @override
  String get setting_error => 'There is no setting info';

  @override
  String get setting_button_info => 'save setting info';

  @override
  String get setting_success => 'setting info was successfully updated';

  @override
  String get entrance_title => 'Entrance';

  @override
  String get entrance_message => 'We will move to setting menu for using ChatGPT client';

  @override
  String get entrance_button_label => 'to Settings menu';

  @override
  String get chat_view_title => 'Privtatize AI';

  @override
  String get chat_view_hint_text => 'please input your message';
}
