import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:privtatize_ai/app_localizations.dart';
import 'package:privtatize_ai/src/screens/chat_view.dart';
import 'package:privtatize_ai/src/services/crypt_service.dart';

const _storage = FlutterSecureStorage();

Future<bool> validatePassword(String password) async {
  var bytes = utf8.encode(password);
  var hashedPassword = sha256.convert(bytes).toString();
  var storedPasswordHash = await _storage.read(key: 'passwordHash');
  return hashedPassword == storedPasswordHash;
}

class ValidatePasswordScreen extends StatelessWidget {
  const ValidatePasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // パスワード検証用のUIをここに実装
    TextEditingController passwordController = TextEditingController();
    // パスワード検証処理が成功したら、Chatに遷移
    void validateAndNavigate() async {
      bool isValid = await validatePassword(passwordController.text);
      if (isValid) {
        await CryptoService().generateKey(passwordController.text);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ChatPage()),
        );
      }else{
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)?.validate_pass_error ?? '')));
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.validate_pass_title ?? ''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/img/password.png'), 
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(AppLocalizations.of(context)?.validate_pass_info ?? ''),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: TextField(
                controller: passwordController,
                obscureText: true, // パスワードを隠す
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)?.validate_pass_text_label ?? '',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: validateAndNavigate,
              child: Text(AppLocalizations.of(context)?.validate_pass_button_label ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}
