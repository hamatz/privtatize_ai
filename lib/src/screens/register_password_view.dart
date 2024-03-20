import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:privtatize_ai/app_localizations.dart';
import 'package:privtatize_ai/src/screens/entrance_view.dart' as ent_view;
import 'package:privtatize_ai/src/services/crypt_service.dart';

const _storage = FlutterSecureStorage();

Future<bool> registerPassword(String password) async {
   // 失敗時の処理をなんか入れる。丁寧にパスワードに使うべき文字列の条件とかチェックするなら例外とかはここで発生させる
  var bytes = utf8.encode(password);
  var hashedPassword = sha256.convert(bytes).toString();
  await _storage.write(key: 'passwordHash', value: hashedPassword);
  return true;
}

class RegisterPasswordScreen extends StatelessWidget {
  
  const RegisterPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {

    TextEditingController passwordController = TextEditingController();
    // パスワード登録処理が成功したら、ChatScreenに遷移
    void registerAndNavigate() async {
      bool success = await registerPassword(passwordController.text);
      if (success) {
        await CryptoService().generateNewKey(passwordController.text);
        Navigator.of(context).pushReplacement(
          // 設定画面への誘導を行うページに遷移
          MaterialPageRoute(builder: (context) => const ent_view.EntranceScreen()),
        );
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.register_pass_title ?? ''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)?.register_pass_message ?? '',
              style: const TextStyle(fontSize: 24),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/img/welcome_image.png'), 
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(AppLocalizations.of(context)?.register_pass_info ?? ''),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: TextField(
                controller: passwordController,
                obscureText: true, // パスワードを隠す
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)?.register_pass_text_label ?? '',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: registerAndNavigate,
              child: Text(AppLocalizations.of(context)?.register_pass_button_label ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}