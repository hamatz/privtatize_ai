import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja')
  ];

  /// No description provided for @register_pass_title.
  ///
  /// In en, this message translates to:
  /// **'submit password for app activation'**
  String get register_pass_title;

  /// No description provided for @register_pass_message.
  ///
  /// In en, this message translates to:
  /// **'welcome!'**
  String get register_pass_message;

  /// No description provided for @register_pass_info.
  ///
  /// In en, this message translates to:
  /// **'For using this app safely, please submit your password'**
  String get register_pass_info;

  /// No description provided for @register_pass_text_label.
  ///
  /// In en, this message translates to:
  /// **'password'**
  String get register_pass_text_label;

  /// No description provided for @register_pass_button_label.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get register_pass_button_label;

  /// No description provided for @validate_pass_title.
  ///
  /// In en, this message translates to:
  /// **'password authentication'**
  String get validate_pass_title;

  /// No description provided for @validate_pass_info.
  ///
  /// In en, this message translates to:
  /// **'please input your app activation password'**
  String get validate_pass_info;

  /// No description provided for @validate_pass_text_label.
  ///
  /// In en, this message translates to:
  /// **'password'**
  String get validate_pass_text_label;

  /// No description provided for @validate_pass_button_label.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get validate_pass_button_label;

  /// No description provided for @validate_pass_error.
  ///
  /// In en, this message translates to:
  /// **'Password error. Please re-input your password'**
  String get validate_pass_error;

  /// No description provided for @setting_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get setting_title;

  /// No description provided for @setting_error.
  ///
  /// In en, this message translates to:
  /// **'There is no setting info'**
  String get setting_error;

  /// No description provided for @setting_button_info.
  ///
  /// In en, this message translates to:
  /// **'save setting info'**
  String get setting_button_info;

  /// No description provided for @setting_success.
  ///
  /// In en, this message translates to:
  /// **'setting info was successfully updated'**
  String get setting_success;

  /// No description provided for @entrance_title.
  ///
  /// In en, this message translates to:
  /// **'Entrance'**
  String get entrance_title;

  /// No description provided for @entrance_message.
  ///
  /// In en, this message translates to:
  /// **'We will move to setting menu for using ChatGPT client'**
  String get entrance_message;

  /// No description provided for @entrance_button_label.
  ///
  /// In en, this message translates to:
  /// **'to Settings menu'**
  String get entrance_button_label;

  /// No description provided for @chat_view_title.
  ///
  /// In en, this message translates to:
  /// **'Privtatize AI'**
  String get chat_view_title;

  /// No description provided for @chat_view_hint_text.
  ///
  /// In en, this message translates to:
  /// **'please input your message'**
  String get chat_view_hint_text;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ja': return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
