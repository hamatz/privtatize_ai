import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:privtatize_ai/src/services/crypt_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TextSettingItemWidget extends StatefulWidget {
  final String title;
  final String value;
  final bool isEncrypted;

  const TextSettingItemWidget({super.key, required this.title, required this.value, required this.isEncrypted});

  @override
  TextSettingItemWidgetState createState() => TextSettingItemWidgetState();
}

class TextSettingItemWidgetState extends State<TextSettingItemWidget> {
  late TextEditingController _controller;
  final cryptoService = CryptoService();
  final storage = FlutterSecureStorage();
  late bool _isEncrypted;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _isEncrypted = widget.isEncrypted;
  }

  Future<bool> save() async {
    Map<String, dynamic> settingData = {};
    String value = _controller.text;
    if (_isEncrypted) {
      value = await cryptoService.encrypt(value);
    }
    settingData = {
      'value': value,
      'isEncrypted': _isEncrypted,
    };
    String key = widget.title ;
    // MapをJSON文字列に変換して保存
    String jsonValue = jsonEncode(settingData);
    await storage.write(key: key, value: jsonValue);
    setState(() {

    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(widget.title),
          trailing: Switch(
              value: _isEncrypted,
              onChanged: _isEncrypted ? null : (bool value) {
              setState(() {
                  _isEncrypted = value;
                });
              },
              activeColor: Colors.blue, // トグルがONの時の色
              inactiveThumbColor: _isEncrypted ? Colors.grey : Colors.red, // トグルがOFFの時の色、無効状態であればグレー
              inactiveTrackColor: _isEncrypted ? Colors.grey[300] : Colors.red[200], // トラックの色も同様に
          ),
          subtitle: TextField(
            controller: _controller,
            onChanged: (newValue) {
                  _controller.text = newValue; 
            },
            obscureText: _isEncrypted,
          ),
        ),
      ],
    );
  }
}