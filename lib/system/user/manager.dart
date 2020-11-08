import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../utils/utils.dart';
import 'user.dart';

/// This manages the [User]s in the system.
///
/// This manager handles everything that would be needed to control a [User]
/// within the system. That includes ensuring the correct authorization is
/// provided for the OS.
class UserManager {
  /// THis manager's file containing all of the users.
  File _usersFile;

  /// This system's list of [users].
  List<User> _users = [];
  final _logger = Logger("UserManager");

  /// This manager's currently active [user].
  User current;

  /// This manager's currently running instance.
  static UserManager _instance;
  factory UserManager() => _instance ?? UserManager._();
  factory UserManager.withUserFile(String path) => UserManager._(path: path);

  /// This provides a means of configuring where this manager looks for users.
  ///
  /// By offering a default configuration this allows for a consistent way to
  /// access the proper user. With this set up the CI will not fail due to
  /// invalid permissions on the filesystem.
  ///
  /// In the event that the path doesn't exist we ensure that it is created.
  UserManager._({String path = '/home/.users'}) {
    _usersFile = File(path);
    if (!_usersFile.existsSync()) {
      _logger.warning('Creating users file.');
      _usersFile.createSync();
    } else {
      _logger.info('Found User file');
    }

    _parseUsersFile();
    _instance = this;
  }

  /// This parses the [userFile] provided upon initiation of this manager.
  ///
  /// THis parses the current user file. By parsing the users installed on the
  /// system
  _parseUsersFile() {
    String f = _usersFile.readAsStringSync();
    // This handles the niche case where the usersFile is just an empty string
    // either due to an external modification or improper formatting. This
    // occurred when the file had been generated in memory.
    if (f.trim().isNotEmpty) {
      // Decode the users
      _logger.info('Decoding users');
      // TODO: Do more than have more than B64 the list of users
      //  passwords are still encoded differently but it would help with security.
      String usersString = utf8.decode(base64Decode(f));
      Map<String, dynamic> userListMap = json.decode(usersString);
      List<dynamic> users = userListMap['users'];
      _logger.info('Users decoded.');
      // Parse each user and add them to the list of users available for use.
      users.forEach((userString) {
        Map<String, dynamic> userMap = jsonDecode(userString as String);
        final user = User.fromMap(userMap);
        _users.add(user);
      });
    }
    _logger.info('Loaded Users');
  }

  /// Verifies if this [username] matches any of the users in the system.
  bool checkValidUser(String username) {
    for (final user in _users) {
      if (user.username == username) {
        return true;
      }
    }
    return false;
  }

  /// Attempts to login to the system.
  ///
  /// If the attempt is authorized the system will proceed, otherwise
  /// a non-descriptive error will be thrown.
  User login(String username, EncryptedString password) {
    final validUser = checkValidUser(username);
    if (!validUser) {
      return null;
    }

    final user = _users.singleWhere((user) => user.username == username);
    if (user.password != password.toString()) {
      return null;
    }

    current = user;
    return user;
  }

  /// This creates a new user for the system.
  ///
  /// The [password] should be of type [EncryptedString] when sent through the system.
  /// This allows for the rest of the application to not need to know how to
  /// encrypt and decrypt the user information.
  void createUser({
    @required String username,
    @required EncryptedString password,
  }) {
    // TODO: Fix name in creation of user
    final user = User(username: username, password: password, name: username);
    _logger.fine('Creating User: $username');
    _users.add(user);
    // TODO: Create home file if not available
    _updateUsersFile();
  }

  /// [updateUsersFile] ensures that the listing of all users.
  ///
  /// Updates, and encodes the current users available to the system.
  void _updateUsersFile() async {
    _logger.info('Updating users');
    String users = '{"users":[';
    // Ensure the current set of users is kept as the file is overwritten each time.
    for (final user in _users) {
      users += '${jsonEncode("{$user}")},';
    }
    users = users.substring(0, users.lastIndexOf(','));
    users += ']}';

    _usersFile.writeAsString(
        base64Encode(
          utf8.encode(users),
        ),
        mode: FileMode.writeOnly);
    _logger.info('Users updated.');
  }
}
