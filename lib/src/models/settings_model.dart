import 'package:flutter/material.dart';
import 'package:privtatize_ai/src/widgets/text_setting_item.dart';
import 'package:privtatize_ai/src/widgets/profile_setting_item.dart';

abstract class SettingItem {
  Widget buildWidget(BuildContext context);
}

class UserProfileSettingItem extends SettingItem {
  final String username;
  final String imagePath;

  UserProfileSettingItem({required this.username, required this.imagePath});

  @override
  Widget buildWidget(BuildContext context) {
    return UserProfileSettingItemWidget(username: username, imagePath: imagePath);
  }
}

class TextSettingItem extends SettingItem {
  final String title;
  final String value;
  final bool isEncrypted;

  TextSettingItem({required this.title, required this.value, required this.isEncrypted});

  @override
  Widget buildWidget(BuildContext context) {
    return TextSettingItemWidget(title: title, value: value, isEncrypted: isEncrypted);
  }
}
