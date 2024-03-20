import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:privtatize_ai/app_localizations.dart';
import 'package:privtatize_ai/src/models/settings_model.dart';
import 'package:privtatize_ai/src/widgets/text_setting_item.dart';
import 'package:privtatize_ai/src/widgets/profile_setting_item.dart';
import 'package:privtatize_ai/src/services/crypt_service.dart';
import 'package:privtatize_ai/src/services/setting_update_event.dart';
import 'package:privtatize_ai/src/global.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  final storage = const FlutterSecureStorage();
  final cryptoService = CryptoService();
  List<SettingItem> settings = [];
  late Future<List<SettingItem>> settingsFuture;
    // 各ウィジェットのインスタンスを管理するリスト
  List<GlobalKey<TextSettingItemWidgetState>> itemKeys = [];
  late GlobalKey profileItemKey;

  @override
  void initState() {
    super.initState();
    settingsFuture = loadSettings();
    profileItemKey = GlobalKey();
  }
  Future<void> saveSettings() async {
    for (var key in itemKeys) {
      await key.currentState?.save();
    }
    await (profileItemKey.currentState as UserProfileSettingItemState?)?.save();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)?.setting_success ?? '')));

      // 設定の再読み込み
    var loadedSettings = await loadSettings();
    if(mounted){
      setState(() {
        settingsFuture = Future.value(loadedSettings);
      });
    }
    // 保存処理が完了した後にイベントを発火
    eventBus.fire(SettingsUpdatedEvent());
  }
  Future<List<SettingItem>> loadSettings() async {
    List<SettingItem> loadedSettings = [];
    // キーが存在するかどうかを確認するためのフラグ
    bool hasSettings = false;
    // 保存時に使用したキーのリスト
    List<String> keys = ['UserProfile', 'Azure API Key', 'Azure OpenAI Base Name', 'Azure OpenAI API Version', 'Azure OpenAI Deployment Name'];

    for (var key in keys) {
      String? jsonValue = await storage.read(key: key);
      if (jsonValue != null) {
        hasSettings = true;
        Map<String, dynamic> settingData = jsonDecode(jsonValue);
        String value = ""; 
        if (key == 'UserProfile') {
            loadedSettings.add(UserProfileSettingItem(
              username: settingData['username'],
              imagePath: settingData['imagePath'],
            ));
        } else {
              try {
                if (settingData.containsKey('isEncrypted') && settingData['isEncrypted']) {
                  value = await cryptoService.decrypt(settingData['value']);
                } else {
                  value = settingData['value'];
                }
                //print("title : $key  / value : $value");
              } catch (e) {
                print("Error decrypting $key: $e");
                continue; // エラーが発生した場合、このキーの処理をスキップ
              }
              loadedSettings.add(TextSettingItem(
                title: key,
                value: value,
                isEncrypted: settingData.containsKey('isEncrypted') ? settingData['isEncrypted'] : false,
              ));
        }
      }
    }
    // 一つでも設定が読み込まれた場合はそのリストを返す
    if (hasSettings) {
      return loadedSettings;
    }
    // 保存された設定が一つもない場合はデフォルトの設定リストを返す
    return [
      UserProfileSettingItem(username: "未登録", imagePath: "assets/img/avatar.png"),
      TextSettingItem(title: "Azure API Key", value: "Your API Key Here", isEncrypted: true),
      TextSettingItem(title: "Azure OpenAI Base Name", value: "Your API BaseName Here", isEncrypted: true),
      TextSettingItem(title: "Azure OpenAI API Version", value: "Your API version Here", isEncrypted: false),
      TextSettingItem(title: "Azure OpenAI Deployment Name", value: "Your Deployment Name Here", isEncrypted: false),
    ];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.setting_title ?? ''),
      ),
      body: FutureBuilder<List<SettingItem>>(
        future: settingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              itemKeys = List.generate(snapshot.data!.length, (_) => GlobalKey<TextSettingItemWidgetState>());
              // 設定情報を表示
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final settingItem = snapshot.data![index];
                  GlobalKey key;
                  // UserProfileSettingItemの場合
                  if (settingItem is UserProfileSettingItem) {
                    key = profileItemKey;
                    return UserProfileSettingItemWidget(
                      key: key, // GlobalKeyを渡す
                      username: settingItem.username,
                      imagePath: settingItem.imagePath,
                    );
                  }
                  // TextSettingItemの場合
                  else if (settingItem is TextSettingItem) {
                    key = itemKeys[index]; // 対応するGlobalKeyをリストから取得
                    return TextSettingItemWidget(
                      key: key, // GlobalKeyを渡す
                      title: settingItem.title,
                      value: settingItem.value,
                      isEncrypted: settingItem.isEncrypted,
                    );
                  }
                    // どの条件にも当てはまらない場合、デフォルトのWidgetを返す
                    return const SizedBox();
                },
              );
            } else {
              // エラー表示
              return Center(child: Text(AppLocalizations.of(context)?.setting_error ?? ''));
            }
          } else {
            // ローディング表示
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            saveSettings();
        },
        child: Icon(Icons.save),
        tooltip: AppLocalizations.of(context)?.setting_button_info ?? '',
      ),
    );
  }
  }