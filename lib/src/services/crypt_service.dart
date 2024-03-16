import 'dart:math';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart' as pc;

class CryptoService {
  static final CryptoService _instance = CryptoService._internal();
  final secureStorage = const FlutterSecureStorage();
  final String saltKey = 'saltKey';
  final String iterationCountKey = 'iterationCountKey';
  late KeyDerivator _keyDerivator;
  Uint8List? _key;

  factory CryptoService() {
    return _instance;
  }

  CryptoService._internal() {
    // PBKDF2の初期化
    _keyDerivator = KeyDerivator('SHA-1/HMAC/PBKDF2');
  }

  Uint8List createRandomSalt(int length) {
    final random = Random.secure();
    var bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return bytes;
  }
  // 1: 入力されたパスワードを引数として、PBKDF2で鍵を新規に生成する
  // コンテンツ鍵は生成後、メモリ上に保持することとし、鍵の生成にこの後も利用するsaltやイテレーション回数等の情報はflutter_secure_storageに保存する
  Future<void> generateNewKey(String password) async {
    var salt = _createSalt();
    // print("generateNewKey:salt : $salt");
    int iterationCount = 10000;
    var param = Pbkdf2Parameters(salt, iterationCount, 32);
    _keyDerivator.init(param);
    _key = _keyDerivator.process(Uint8List.fromList(utf8.encode(password)));
    await secureStorage.write(key: saltKey, value: base64Encode(salt));
    await secureStorage.write(key: iterationCountKey, value: iterationCount.toString());
  }

  Uint8List _createSalt() {
    Uint8List salt = createRandomSalt(16);
    return salt;
  }
  // 2: 入力されたパスワードを引数として、flutter_secure_storageに保存していたsalt等を利用してPBKDF2でコンテンツ鍵を生成し、メモリ上に保持する
  Future<void> generateKey(String password) async {
    // Saltとイテレーション回数をsecureStorageから取得
    String? storedSalt = await secureStorage.read(key: saltKey);
    String? storedIterationCount = await secureStorage.read(key: iterationCountKey);

    if (storedSalt != null && storedIterationCount != null) {
      var salt = base64Decode(storedSalt);
      int iterationCount = int.parse(storedIterationCount);

      var param = Pbkdf2Parameters(salt, iterationCount, 32); // AES鍵長に合わせて32
      _keyDerivator.init(param);
      _key = _keyDerivator.process(Uint8List.fromList(utf8.encode(password)));
    } else {
      // Error handling: Salt or iteration count not found
    }
  }
  // 3: コンテンツ鍵を利用して、引数として受け取った文字列を暗号化した後、エンコードの後、文字列として返却する
  Future<String> encrypt(String plainText) async {
    if (_key == null) {
      throw Exception('Key has not been initialized.');
    }
    final iv = secureRandom(16);
    final paddedParams = pc.PaddedBlockCipherParameters(
      pc.ParametersWithIV(pc.KeyParameter(Uint8List.fromList(_key!)), iv),
      null, // パディングに関する追加パラメータが必要な場合はここに指定しますが、通常はnull
    );
    final cipher = pc.PaddedBlockCipher('AES/CBC/PKCS7')
      ..init(true, paddedParams); // trueで暗号化モードを指定、修正されたパラメータを使用
    final inputAsUint8List = Uint8List.fromList(utf8.encode(plainText));
    final encrypted = cipher.process(inputAsUint8List);
    final result = base64Encode(iv + encrypted);
    return result;
  }
  Uint8List secureRandom(int length) {
    final rnd = pc.SecureRandom("AES/CTR/AUTO-SEED-PRNG");
    final key = Uint8List(16); // 128 bit
    final keyParam = pc.KeyParameter(key);
    final params = pc.ParametersWithIV(keyParam, Uint8List(16)); // IVはここでは使用しない
    rnd.seed(params);
    return rnd.nextBytes(length);
  }
  // 4: 引数として受け取った暗号文字列を、コンテンツ鍵を使って復号した後、文字列として返却する
  Future<String> decrypt(String encryptedBase64Text) async {
    if (_key == null) {
      throw Exception('Key has not been initialized.');
    }
    final encryptedBytesWithIv = base64Decode(encryptedBase64Text);
    final iv = encryptedBytesWithIv.sublist(0, 16);
    final encryptedBytes = encryptedBytesWithIv.sublist(16);
    final paddedParams = pc.PaddedBlockCipherParameters(
      pc.ParametersWithIV(pc.KeyParameter(Uint8List.fromList(_key!)), iv),
      null, // 復号処理ではパディングに関する追加パラメータは通常不要
    );

    final cipher = pc.PaddedBlockCipher('AES/CBC/PKCS7')
      ..init(false, paddedParams); // falseで復号モードを指定
    try {
      final decryptedBytes = cipher.process(encryptedBytes);
      return utf8.decode(decryptedBytes);
    } catch (e) {
      print('復号化エラー: $e');
      throw Exception('復号化に失敗しました。');
    }
  }
}

