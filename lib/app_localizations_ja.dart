import 'app_localizations.dart';

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get register_pass_title => '起動用パスワード登録';

  @override
  String get register_pass_message => 'ようこそ！';

  @override
  String get register_pass_info => '安全に本アプリをご利用いただくため、起動用のパスワードを登録してください';

  @override
  String get register_pass_text_label => 'パスワード';

  @override
  String get register_pass_button_label => '登録する';

  @override
  String get validate_pass_title => 'パスワード認証';

  @override
  String get validate_pass_info => '起動用のパスワードを入力してください。';

  @override
  String get validate_pass_text_label => 'パスワード';

  @override
  String get validate_pass_button_label => 'ログイン';

  @override
  String get validate_pass_error => 'パスワードエラーです。再度入力してください';

  @override
  String get setting_title => '設定';

  @override
  String get setting_error => '設定情報がありません';

  @override
  String get setting_button_info => '設定を保存';

  @override
  String get setting_success => '新しい設定が保存されました';

  @override
  String get entrance_title => 'Entrance';

  @override
  String get entrance_message => 'Azureとの接続に利用するアクセストークン等の設定情報入力ページに遷移します';

  @override
  String get entrance_button_label => '設定画面へ';

  @override
  String get chat_view_title => 'Privtatize AI';

  @override
  String get chat_view_hint_text => 'メッセージを入力';
}
