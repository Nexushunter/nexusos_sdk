import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexusos_sdk/nexusos_sdk.dart';

void main() {
  group('UserManager', () {
    final userFilePath = './users';
    final userFile = File(userFilePath);
    tearDownAll(() {
      if (userFile.existsSync()) {
        userFile.deleteSync();
      }
    });

    group('Defaults: No File', () {
      test('Creates Missing Users File', () async {
        expect(userFile.existsSync(), isFalse);
        UserManager(path: userFilePath);
        expect(userFile.existsSync(), isTrue);
      });
      test('Has no users', () {
        var um = UserManager(path: userFilePath);
        expect(um.users, isEmpty);
      });
      test('No default user', () {
        var um = UserManager(path: userFilePath);
        expect(um.current, isNull);
      });
    });

    group('Defaults: With File', () {
      test('Loads users', () {
        var um = UserManager(path: userFilePath);
        expect(um.users, isEmpty);
      });
      test('No default user', () {
        var um = UserManager(path: userFilePath);
        expect(um.current, isNull);
      });
    });

    group('Updates a user\'s information', () {
      UserManager um;
      setUpAll(() {
        _populateTestUsers(userFile);
        um = UserManager(path: userFilePath);
      });
      group('Fails when', () {
        test('The user is not present', () {
          bool succeeded = um.update('user2', name: 'TestUser');
          expect(succeeded, isFalse);
          var user = um.fetchUser('user2');
          expect(user, isNull);
        });
        test('The password is the same', () {
          final passwd = EncryptedString(toEncrypt: 'some1bspasswd');
          bool succeeded = um.update('user1', password: passwd);
          expect(succeeded, isFalse);
          var user = um.fetchUser('user1');
          expect(passwd.toString() == user.passwd, isTrue);
        });
        test('The name is the same', () {
          final name = 'user1';
          bool succeeded = um.update('user1', name: name);
          expect(succeeded, isFalse);
          var user = um.fetchUser('user1');
          expect(user.name == name, isTrue);
        });
      });

      // Demonstrates partial updates.
      test('The name', () {
        bool succeeded = um.update('user1', name: 'TestUser');
        expect(succeeded, isTrue);
        var user = um.fetchUser('user1');
        expect(user.name, 'TestUser');
      });
      test('The password', () {
        final passwd = EncryptedString(toEncrypt: 'thisIsANewPassword');
        bool succeeded = um.update('user1', password: passwd);
        expect(succeeded, isTrue);
        var user = um.fetchUser('user1');
        expect(passwd.toString() == user.passwd, isTrue);
      });
    });

    test('Creates a user', () async {
      var um = UserManager(path: userFilePath);
      bool succeeded = um.create('user2', EncryptedString(toEncrypt: 'somebs'));
      expect(succeeded, isTrue);
    });
    test('Fails to create a user when username is taken', () async {
      _populateTestUsers(userFile);
      var um = UserManager(path: userFilePath);
      bool succeeded =
          um.create('user1', EncryptedString(toEncrypt: 'some1bspasswd'));
      expect(succeeded, isFalse);
    });
    test('Logs a user in', () async {
      _populateTestUsers(userFile);
      var um = UserManager(path: userFilePath);
      bool succeeded =
          um.login('user1', EncryptedString(toEncrypt: 'some1bspasswd'));
      expect(succeeded, isTrue);
      expect(um.fetchUser('user1') == um.current, isTrue);
    });
    test('Fails to log an invalid user in', () async {
      _populateTestUsers(userFile);
      var um = UserManager(path: userFilePath);
      bool succeeded =
          um.login('user2', EncryptedString(toEncrypt: 'some2bspasswd'));
      expect(succeeded, isFalse);
    });

    group('Export Users', () {
      test('asJsonString', () {
        _populateTestUsers(userFile, asJsonString: true);
        var um = UserManager(path: userFilePath, asJsonString: true);
        var userData = um.exportUsers(asJsonString: true);
        var users = _buildUsersList();
        expect(userData.userString == users, isTrue);
        expect(userData.asJsonString, isTrue);
      });
      test('Default', () {
        _populateTestUsers(userFile);
        var um = UserManager(path: userFilePath);
        var userData = um.exportUsers();
        var users = base64Encode(utf8.encode(_buildUsersList()));
        expect(userData.userString == users, isTrue);
        expect(userData.asJsonString, isFalse);
      });
    });
  });
}

_populateTestUsers(File file, {int count = 1, bool asJsonString = false}) {
  var users = _buildUsersList(count: count);
  if (!file.existsSync()) {
    file.createSync();
  }

  users = asJsonString ? users : base64Encode(utf8.encode(users));

  file.writeAsStringSync(users);
}

_buildUsersList({int count = 1}) {
  var users = '';
  for (var i = 0; i < count; i++) {
    var user = User(
        username: 'user${i + 1}',
        password: EncryptedString(toEncrypt: 'some${i + 1}bspasswd'));
    users += '${jsonEncode("{$user}")},';
  }
  users = users.substring(0, users.length - 1);
  return '{"users":[$users]}';
}
