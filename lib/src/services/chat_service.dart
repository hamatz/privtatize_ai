import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// learn from https://github.com/DigitalStation-ca/FlutterChatGPT
enum MessageType {
  user,
  assistant,
  system
}
class ChatMessage {
  String content;
  MessageType messageType;

  Map<String, String> toJson() {
    return {'role': messageType.name, 'content': content};
  }
  ChatMessage({required this.messageType, required this.content});
}
// learn from https://zenn.dev/kawanji01/articles/909e68406d604c
class ChatRequest {
  final String model;
  final List<ChatMessage> messages;
  final int? maxTokens;
  final double? temperature;
  final int? topP;
  final int? n;
  bool? stream = false;
  final double? presencePenalty;
  final double? frequencyPenalty;
  final String? stop;

  ChatRequest({
    required this.model,
    required this.messages,
    this.maxTokens,
    this.temperature,
    this.topP,
    this.n,
    this.stream,
    this.presencePenalty,
    this.frequencyPenalty,
    this.stop,
  });

  String toJson() {
    Map<String, dynamic> jsonBody = {
      'model': model,
      'messages': List<Map<String, dynamic>>.from(
          messages.map((message) => message.toJson())),
    };
    if (maxTokens != null) {
      jsonBody.addAll({'max_tokens': maxTokens});
    }

    if (temperature != null) {
      jsonBody.addAll({'temperature': temperature});
    }

    if (topP != null) {
      jsonBody.addAll({'top_p': topP});
    }

    if (n != null) {
      jsonBody.addAll({'n': n});
    }

    if (stream != null) {
      jsonBody.addAll({'stream': stream});
    }

    if (presencePenalty != null) {
      jsonBody.addAll({'presence_penalty': presencePenalty});
    }

    if (frequencyPenalty != null) {
      jsonBody.addAll({'frequency_penalty': frequencyPenalty});
    }

    if (stop != null) {
      jsonBody.addAll({'stop': stop});
    }
    return json.encode(jsonBody);
  }
}

class ChatService {
  String endpoint = "APIのエンドポイント";
  String apiKey = "APIキー";

  ChatService({required this.endpoint, required this.apiKey, required});

  String bufferedChunk = ""; // 不完全なJSONへの対策用
  List<dynamic> collectedChunks = []; 
  bool isValidJson(String input) {
    try {
      json.decode(input);
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<dynamic> chat(
    ChatRequest chatRequest
  ) async* {
    final StreamController<dynamic> controller = StreamController<dynamic>();
    if (chatRequest.stream != true) {
          final response = await http.post(
            Uri.parse(endpoint),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'api-key': apiKey ,
            },
            body: chatRequest.toJson(),
          );
          if (response.statusCode == 200) {
            final body = jsonDecode(response.body);
            String? message = body['choices']?.first['message']['content'];
            if (message != null && message.isNotEmpty) {
              controller.add(body);
            } else {
              print('Failed to parse response body.');
            }
          } else {
            print('Failed to fetch from API. Check your endpoint and key.');
          }
          await controller.close(); // 非ストリーミング応答のため、ここでストリームを閉じる
    }else{
        requestStreaming(chatRequest:chatRequest, controller: controller);
    }    
    yield* controller.stream;
  }
    void requestStreaming({
        required ChatRequest chatRequest,
        required StreamController<dynamic> controller,
  }) async {
    try {
      final request = http.Request('POST', Uri.parse(endpoint))
        ..headers.addAll({
              'Content-Type': 'application/json',
              'api-key': apiKey ,
        })
        ..body = chatRequest.toJson();
      final streamedResponse = await http.Client().send(request);
      if (streamedResponse.statusCode == 200) {
        streamedResponse.stream.transform(utf8.decoder).listen(
          (chunk) {
                  bufferedChunk += chunk; 
                  List<String> splitChunks = bufferedChunk
                      .split('\n')
                      .where((line) => line.trim().startsWith('data: '))
                      .toList();
                  for (String singleChunk in splitChunks) {
                    String modifiedText =
                    singleChunk.replaceFirst("data:", "").trim();
                    if (modifiedText == '[DONE]') {
                      continue;
                    }
                    if (!isValidJson(modifiedText)) {
                      continue;
                    }
                    Map<String, dynamic> parsedData = json.decode(modifiedText);

                    if (parsedData['choices'] != null &&
                        parsedData['choices'].isNotEmpty) {
                      String? content = parsedData['choices'][0]['delta']['content'];
                      //print('content: $parsedData');
                      if (content != null) { // データの中身の存在確認はするけどChunkそのまま返した方が便利だと思うので敢えてこっちをセットしてる
                        collectedChunks.add(parsedData);
                      }
                      controller.add(parsedData);
                    }
                    bufferedChunk = bufferedChunk.replaceFirst(singleChunk, "");
                  }
          },
          onDone: () {
            controller.close();
          } ,
          onError: (error) => controller.addError('Error: $error'),
        );
      } else {
        controller.addError('Failed to fetch data: ${streamedResponse.statusCode}');
        controller.close();
      }
    } catch (e) {
      controller.addError('Error: $e');
      controller.close();
    }
  }
}