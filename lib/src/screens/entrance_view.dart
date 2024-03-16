import 'package:flutter/material.dart';
import 'package:privtatize_ai/src/screens/setting_view.dart' as setting_view;
import 'package:privtatize_ai/src/screens/chat_view.dart' as chat_view;

class EntranceScreen extends StatelessWidget {
  const EntranceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // パスワード検証処理が成功したら、設定画面に遷移
    Future<void> jumpToSettings() async {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => chat_view.ChatPage()),
        (Route<dynamic> route) => false,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => setting_view.SettingsScreen()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrance'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/img/to_setting.png'), 
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Azureとの接続に利用するアクセストークン等の設定情報入力ページに遷移します'),
            ),
            ElevatedButton(
              onPressed: jumpToSettings,
              child: const Text('設定画面へ'),
            ),
          ],
        ),
      ),
    );
  }
}

