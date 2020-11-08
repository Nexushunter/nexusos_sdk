import 'dart:convert';

import 'package:crypto/crypto.dart';

class EncryptedString {
  String _value;
  EncryptedString({String toEncrypt = ""}) : _value = _encrypt(toEncrypt);

  factory EncryptedString.fromEncrypted(String encrypted) =>
      EncryptedString().._value = encrypted;

  static String _encrypt(String _string) =>
      sha256.convert(utf8.encode(_string)).toString();

  @override
  String toString() {
    return _value;
  }
}
