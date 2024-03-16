import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:privtatize_ai/src/screens/chat_view.dart' as chat_view;
import 'package:privtatize_ai/src/services/crypt_service.dart';

const _storage = FlutterSecureStorage();

Future<bool> validatePassword(String password) async {
  var bytes = utf8.encode(password);
  var hashedPassword = sha256.convert(bytes).toString();
  var storedPasswordHash = await _storage.read(key: 'passwordHash');
  return hashedPassword == storedPasswordHash;
}

class ValidatePasswordScreen extends StatelessWidget {
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
          MaterialPageRoute(builder: (context) => chat_view.ChatPage()),
        );
      }else{
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('パスワードエラーです。再度入力してください')));
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('パスワード認証'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/img/password.png'), 
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('起動用のパスワードを入力してください。'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: TextField(
                controller: passwordController,
                obscureText: true, // パスワードを隠す
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'パスワード',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: validateAndNavigate,
              child: Text('ログイン'),
            ),
          ],
        ),
      ),
    );
  }
}
