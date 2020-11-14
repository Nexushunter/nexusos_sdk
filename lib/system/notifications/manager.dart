import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../user.dart';
import 'notification.dart';

/// This manager ensures that all notifications are handled within the system.
///
/// The [NotificationManager] provides a system-wide notification manager. It
/// ensures that notifications are delivered to the expected user and stores the
/// current list of notifications in the event a user has logged out.
class NotificationManager extends ChangeNotifier {
  NotificationManager() : _logger = Logger("NotificationManager");

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
        '${_current.username}': _pending,
      };
      _userPending.addAll(userEntries);
    }
    // Load the new user
    _current = user;
    // Load pending with user notifications
    // Notify dependants
    pending = _userPending[_current.username] ?? [];
  }

  List<Notification> _pending = [];
  set pending(List<Notification> pending) {
    _pending = pending;
    notifyListeners();
  }

  List<Notification> get pending => _pending;

  Stream<Notification> get pendingNotifications =>
      Stream.fromIterable(_pending);

  Map<String, List<Notification>> _userPending = {};
  Map<String, List<Notification>> get allExternalPending => _userPending;

  /// Push a [notification] to this manager.
  ///
  /// Pushes a [notification] for the specified [user], by default this is the
  /// [_current] user registered with this manager.
  bool create(Notification notification) {
    _logger.fine("Adding $notification");
    if (notification.user == null && _current == null) {
      return false;
    }
    if (notification.user == null) {
      _userPending['${_current.username}'].add(notification);
    } else {
      pending = [notification, ..._pending];
    }
    return true;
  }

  void clear() {
    pending = [];
  }
}
