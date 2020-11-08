import 'package:logging/logging.dart';

import '../user.dart';
import 'notification.dart';

/// This manager ensures that all notifications are handled within the system.
///
/// The [NotificationManager] provides a system-wide notification manager. It
/// ensures that notifications are delivered to the expected user and stores the
/// current list of notifications in the event a user has logged out.
class NotificationManager {
  static final _instance = NotificationManager._();
  NotificationManager._() : _logger = Logger("NotificationManager");
  factory NotificationManager() => _instance;

  final Logger _logger;
  User _current;

  /// Updates the current [user].
  ///
  /// Sets the current [user] to be the newly selected [user].Before
  /// attempting to show the new [user] their notifications this manager stores
  /// the previous [user]'s notifications.
  set currentUser(User user) {
    if (_current != null && _current != user) {
      _logger.fine("Storing ${_current.username}'s notifications");

      // Write the state of the original user's notifications
      final userEntries = <String, List<Notification>>{
        '${_current.username}': pending,
      };
      _userPending.addAll(userEntries);
    }
    // Load the new user
    _current = user;
    // Load pending with user notifications
    // Notify dependants
    pending = _userPending[_current.username] ?? [];
  }

  List<Notification> pending = [];

  /// Tap into the most recently received [Notification].
  Stream<Notification> get alertStream {
    return Stream.fromIterable(
      pending.getRange(
        0,
        (pending.length >= 1)
            ? 1
            : 0, // In the event that there are no entries return []
      ),
    );
  }

  Map<String, List<Notification>> _userPending = {};

  /// Push a [notification] to this manager.
  ///
  /// Pushes a [notification] for the specified [user], by default this is the
  /// [_current] user registered with this manager.
  push(Notification notification, {User user}) {
    _logger.fine("Adding $notification");
    if (user == null) {
      _userPending['${user.username}'].add(notification);
    } else {
      pending = [notification, ...pending];
    }
  }
}
