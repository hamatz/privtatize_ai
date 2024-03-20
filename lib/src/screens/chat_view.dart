
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:privtatize_ai/app_localizations.dart';
import 'package:privtatize_ai/src/services/chat_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:privtatize_ai/src/screens/setting_view.dart' as setting_view;
import 'package:privtatize_ai/src/services/crypt_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:privtatize_ai/src/global.dart';
import 'package:privtatize_ai/src/services/setting_update_event.dart';
import 'package:url_launcher/url_launcher.dart';

class MessagePair {
  String question;
  String response;

  MessagePair({this.question = "", this.response = ""});
}

void _launchURL(String url) async {
    final Uri _url = Uri.parse(url);
    if (await canLaunchUrl(_url)) {
      await launchUrl(_url);
    } else {
      throw 'Could not launch $url';
    }
}


class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  late ChatService chatService;
  final storage = const FlutterSecureStorage();
  final cryptoService = CryptoService();
  //List<String> messages = [];
  List<ChatMessage> chatMessages=[];
  List<String> collectedChunks = []; 
  TextEditingController messageController = TextEditingController();
  String currentResponse = ""; // 現在のAPI応答を保持するための変数
  String azureOpenaiKey="";
  String azureApiBaseUrl="";
  String azureApiVersion="";
  String azureDeploymentName="";
  String azureOpenaiEndpointUrl="";
  StreamSubscription? _settingsUpdatedSubscription;
  String result="";
  bool isUserTyping=true;

  late final ChatRequest request; 

  @override
  void initState() {
    super.initState();
    _subscribeToSettingsUpdate();
    _loadInitialSettings();
  }

  @override
  void dispose() {
    _settingsUpdatedSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToSettingsUpdate() {
    _settingsUpdatedSubscription = eventBus.on<SettingsUpdatedEvent>().listen((event) {
      _loadInitialSettings();
    });
  }
  Future<void> _loadInitialSettings() async {
    await resolveSettingInfo();
    setState(() {
          azureOpenaiEndpointUrl = constructAzureOpenAIEndpoint(
              endpointBaseUrl: azureApiBaseUrl,
              deploymentName: azureDeploymentName,
              apiVersion: azureApiVersion,
          );
          chatService = ChatService(
            endpoint: azureOpenaiEndpointUrl,
            apiKey: azureOpenaiKey,
          );
    });
  }
  Future<void> resolveSettingInfo() async {
    List<String> keys = ['Azure API Key', 'Azure OpenAI Base Name', 'Azure OpenAI API Version', 'Azure OpenAI Deployment Name'];

    for (var key in keys) {
      String? jsonValue = await storage.read(key: key);
      if (jsonValue != null) {
        Map<String, dynamic> settingData = jsonDecode(jsonValue);
        String value = ""; 
        try {
          if (settingData.containsKey('isEncrypted') && settingData['isEncrypted']) {
            value = await cryptoService.decrypt(settingData['value']);
          } else {
            value = settingData['value'];
          }
        } catch (e) {
          print("Error decrypting $key: $e");
          continue; // エラーが発生した場合、このキーの処理をスキップ
        }
        if (key == 'Azure API Key') {
          azureOpenaiKey = value;
        } else {
          if (key == 'Azure OpenAI Base Name'){
            azureApiBaseUrl = value;
          } else {
            if(key == 'Azure OpenAI API Version'){
              azureApiVersion = value;
            } else {
              azureDeploymentName = value;
            }
          }
        }
      }
    }
  }
  String constructAzureOpenAIEndpoint({
    required String endpointBaseUrl,
    required String deploymentName,
    required String apiVersion,
  }) {
    final String endpoint = 'https://$endpointBaseUrl.openai.azure.com/openai/deployments/$deploymentName/chat/completions?api-version=$apiVersion';
    return endpoint;
  }
  void fetchChatResponses(ChatRequest request) async {
    currentResponse = ""; // 新しい応答の取得を開始する前にリセット
    chatService.chat(request).listen((response) {
        isUserTyping = false;
        if (response['choices'][0]['delta']['content'] != null && response['choices'][0]['delta']['content'].isNotEmpty) {
          setState(() {
            // 既存のメッセージアイテムを更新するか、新しいメッセージアイテムを追加
            if (currentResponse.isEmpty) {
              chatMessages.add(ChatMessage(messageType: MessageType.assistant, content: response['choices'][0]['delta']['content'])); // 初めてのチャンクの場合、新しいメッセージとして追加
            } else {
              chatMessages[chatMessages.length - 1].content = currentResponse + response['choices'][0]['delta']['content']; // 既存のメッセージを更新
            }
            currentResponse += response['choices'][0]['delta']['content']; // 現在の応答にチャンクを追加
          });
        }
    }, onError: (error) {
      print("Error: $error");
      // エラー処理...
    }, onDone: () {
    // ストリームが終了したことを示す処理
      print("Stream completed");
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.chat_view_title ?? ''),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 設定画面へ遷移
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => setting_view.SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final chatMessage = chatMessages[index];
                Color backgroundColor; 
                Color textColor; 
                EdgeInsets padding;
                switch (chatMessage.messageType) {
                  case MessageType.user:
                    backgroundColor = Colors.blue[100]!;
                    textColor = Colors.black;
                    padding = const EdgeInsets.only(left: 20, right: 80, top: 8, bottom: 8);
                    break;
                  case MessageType.assistant:
                    backgroundColor = Colors.green[100]!; // リプライは緑色系で表示
                    textColor = Colors.black;
                    padding = const EdgeInsets.only(left: 80, right: 20, top: 8, bottom: 8); // アシスタント側に寄せる
                    break;
                  default: // systemなど他のmessageTypeの場合
                    backgroundColor = Colors.grey[200]!;
                    textColor = Colors.black;
                    padding = const EdgeInsets.all(8); // デフォルトのパディング
                }
                return Padding(
                  padding: padding,
                  child: Card(
                    color: backgroundColor, // 背景色を適用
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MarkdownBody(
                        data: chatMessage.content,
                        onTapLink: (text, url, title) {
                          if (url != null) _launchURL(url);
                        },
                        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                          p: Theme.of(context).textTheme.bodyMedium!.copyWith(color: textColor), // テキスト色を適用
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)?.chat_view_hint_text ?? '',
              ),
              onChanged: (text) {
                // 入力が始まったら、リアルタイムで表示を更新
                setState(() {
                  if (chatMessages.isEmpty || chatMessages.last.content != text) {
                    if (chatMessages.isNotEmpty && isUserTyping) {
                      chatMessages.removeLast();
                    }else{
                      isUserTyping = true;
                    }
                    chatMessages.add(ChatMessage(messageType: MessageType.user, content: text));
                  }
                });
              },
              onSubmitted: (text) {
                ChatRequest newRequest = ChatRequest(
                  model: azureDeploymentName,
                  messages: chatMessages,
                  maxTokens: 500,
                  stream: true,
                );
                fetchChatResponses(newRequest);
                messageController.clear(); // テキストフィールドをクリア
              },
            ),
          ),
        ],
      ),
    );
  }
}