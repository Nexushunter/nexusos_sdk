import 'package:flutter/material.dart';
import 'package:nexusos_sdk/nexusos_sdk.dart' as system;

/// A [Notification] is the alert an application wants the user to see.
///
/// A [notification] acts as a way to notify the user of an important event
/// going on within the system.
class Notification {
  /// This notification's [message].
  final String message;

  /// This is what draws the recipient's attention.
  final String title;

  /// This notification's requester.
  final String applicationName;

  /// This application's [icon].
  final Image icon;

  /// The [user] that the application belongs to.
  final system.User user;
  bool _read = false;

  final DateTime _ts;
  DateTime get timestamp => _ts;

  Notification({
    this.title,
    this.message,
    this.applicationName,
    this.icon,
    this.user,
  }) : _ts = DateTime.now();

  /// Marks this as read.
  ///
  /// Provides a simple means to inform the [NotificationManager] that this has
  /// been [read] and the recipient no longer needs to be alerted.
  markAsRead() => _read = true;
  bool get isRead => _read;

  @override
  String toString() {
    return toMap().toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'msg': message,
      'appName': applicationName,
      // 'iconPath': icon.image.toString(),
      'user': user.username,
    };
  }
}
