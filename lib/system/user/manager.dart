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
class UserManager extends ChangeNotifier {
  final _logger = Logger('UserManager');
  User _current;
  User get current => _current;
  set current(User user) {
    _current = user;
    notifyListeners();
  }

  /// This provides a means of configuring where this manager looks for users.
  ///
  /// By offering a default configuration this allows for a consistent way to
  /// access the proper user. With this set up the CI will not fail due to
  /// invalid permissions on the filesystem.
  ///
  /// In the event that the path doesn't exist we ensure that it is created.
  UserManager({String path = '/home/.users', bool asJsonString = false}) {
    _usersFile = File(path);
    if (!_usersFile.existsSync()) {
      _logger.warning('Creating users file.');
      _usersFile.createSync();
    } else {
      _logger.info('Found User file');
    }
    _parseUsersFile(asJsonString: asJsonString);
  }

  /// This manager's file containing all of the users.
  File _usersFile;

  /// This system's list of [users].
  Set<User> _users = {};
  bool create(String username, EncryptedString password, {String name}) {
    if (_checkIfUserExists(username)) {
      return false;
    }
    final user =
        User(username: username, password: password, name: name ?? username);

    _users.add(user);
    notifyListeners();
    return true;
  }

  bool update(String username, {String name, EncryptedString password}) {
    if (!_checkIfUserExists(username)) {
      _logger.warning('Attempted to update invalid user: $username.');
      return false;
    }
    var user = _users.firstWhere((element) => element.username == username);
    return _verifyAndUpdate(user, name: name, password: password);
  }

  bool _verifyAndUpdate(User user, {String name, EncryptedString password}) {
    bool updatedName = false;
    bool updatedPasswd = false;
    if (name != null && name != user.name) {
      updatedName = true;
      user.name = name;
    }
    if (password != null && user.passwd != password.toString()) {
      updatedPasswd = true;
      user.password = password;
    }
    // If neither were updated fail.
    if (!updatedName && !updatedPasswd) {
      return false;
    }
    // Allow partial updates
    return true;
  }

  User fetchUser(String username) =>
      _users.firstWhere((element) => element.username == username,
          orElse: () => null);

  List<User> get users => _users.toList();

  /// Verifies if this [username] matches any of the users in the system.
  bool _checkIfUserExists(String username) {
    for (final user in _users) {
      if (user.username == username) {
        return true;
      }
    }
    return false;
  }

  UserExport exportUsers({bool asJsonString = false}) {
    var userString = '{"users":[';
    // Ensure the current set of users is kept as the file is overwritten each time.
    for (final user in _users) {
      userString += '${jsonEncode("{$user}")},';
    }
    userString = userString.substring(0, userString.lastIndexOf(','));
    userString += ']}';
    if (!asJsonString) {
      userString = base64Encode(utf8.encode(userString));
    }
    return UserExport(asJsonString: asJsonString, userString: userString);
  }

  /// Attempts to login to the system.
  ///
  /// If the attempt is authenticated the system will proceed, otherwise
  /// a non-descriptive error will be thrown.
  bool login(String username, EncryptedString password) {
    final validUser = _checkIfUserExists(username);
    if (!validUser) {
      return false;
    }

    final user = _users.singleWhere((user) => user.username == username);
    if (user.passwd != password.toString()) {
      return false;
    }

    current = user;
    return true;
  }

  /// This parses the [userFile] provided upon initiation of this manager.
  ///
  /// THis parses the current user file. By parsing the users installed on the
  /// system
  _parseUsersFile({asJsonString = false}) {
    String f = _usersFile.readAsStringSync();
    // This handles the niche case where the usersFile is just an empty string
    // either due to an external modification or improper formatting. This
    // occurred when the file had been generated in memory.
    if (f.trim().isNotEmpty) {
      // Decode the users
      _logger.info('Decoding users');
      String usersString = f;
      if (!asJsonString) {
        // TODO: Do more than have more than B64 the list of users
        //  passwords are still encoded differently but it would help with security.
        usersString = utf8.decode(base64Decode(f));
      }
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
    notifyListeners();
  }
}

class UserExport {
  final String userString;
  final bool asJsonString;
  UserExport({this.userString, this.asJsonString});
}
