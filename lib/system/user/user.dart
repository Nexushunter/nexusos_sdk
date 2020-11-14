import 'package:flutter/foundation.dart';

import '../../utils/utils.dart';

/// This system's representation of a [User].
///
/// A [User] represent the end consumer. This is how the system knows what
/// permissions and applications the user has access to.
///
/// It holds all of the standard metadata about the consumer. Including but not
/// limited to:
///   * Their name/username
///   * The password
///   * Home location (within the system)
class User {
  /// This user's preferred [name].
  String name;

  /// This user's [username].
  ///
  // TODO: Update username once USER story for Nexus OS is defined. (Non-final: Breaking change in system)
  final String _username;
  EncryptedString _password;
  String get username => _username;
  String get passwd => _password.toString();
  set password(EncryptedString passwd) {
    _password = passwd;
  }

  String get home => '/home/$_username/';

  User({
    @required String username,
    String name,
    @required EncryptedString password,
  })  : _username = username,
        name = name ?? username,
        _password = password;

  factory User.fromMap(Map<String, dynamic> userMap) => User(
        username: userMap['username'] as String,
        name: userMap['name'] as String,
        password: EncryptedString.fromEncrypted(userMap['pw'] as String),
      );

  // TODO: Handle root

  Map toMap() {
    return <String, dynamic>{
      "name": name,
      "pw": passwd,
      "username": username,
    };
  }

  @override
  String toString() {
    return '"name":"$name","username":"$username","pw":"$passwd"';
  }

  operator ==(Object other) => (other is User)
      ? other.username == _username && other.name == name
      : false;

  @override
  int get hashCode => super.hashCode;
}
