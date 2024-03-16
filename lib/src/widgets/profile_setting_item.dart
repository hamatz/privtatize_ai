import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:privtatize_ai/src/services/crypt_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProfileSettingItemWidget extends StatefulWidget {
  final String username;
  final String imagePath;

  const UserProfileSettingItemWidget({super.key, required this.username, required this.imagePath});

  @override
  UserProfileSettingItemState createState() => UserProfileSettingItemState();
}

// Stateクラス
class UserProfileSettingItemState extends State<UserProfileSettingItemWidget> {
  late String _username;
  late String _imagePath;
  late TextEditingController _controller;
  final cryptoService = CryptoService();
  final storage = FlutterSecureStorage();
  @override
  void initState() {
    super.initState();
    // Widgetのプロパティから初期状態を設定
    _username = widget.username;
    _imagePath = widget.imagePath;
    _controller = TextEditingController(text: _username);
  }

  void updateUsername(String username) {
    setState(() {
      _username = username;
    });
  }

  void updateImagePath(String imagePath) {
    setState(() {
      _imagePath = imagePath;
    });
  }

  Future<void> save() async {
    Map<String, dynamic> settingData = {};
    settingData = {
      'username': _username,
      'imagePath': _imagePath,
    };
    String key = 'UserProfile' ;
    // MapをJSON文字列に変換して保存
    String jsonValue = jsonEncode(settingData);
    await storage.write(key: key, value: jsonValue);
    //print(jsonValue);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(_imagePath),
      ),
      title:  TextField(
            controller: _controller,
            onChanged: (newValue) {
              updateUsername(newValue);
            },
    ),
    );
  }
}
