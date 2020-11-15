import 'package:flutter_test/flutter_test.dart';
import 'package:nexusos_sdk/nexusos_sdk.dart';

void main() {
  final testUser = User(
      username: 'TestUser', password: EncryptedString(toEncrypt: 'password'));
  group('Notification', () {
    test('Default', () {
      test('Serializes correctly', () {
        var notification = Notification(
          title: 'Test',
          message: 'Example Message',
          applicationName: 'Test Application',
          user: testUser,
        );
        final notifMap = notification.toMap();
        expect(notifMap['title'], notification.title);
        expect(notifMap['msg'], notification.message);
        expect(notifMap['appName'], notification.applicationName);
        expect(notifMap['iconPath'], notification.icon.image.toString(),
            skip: true, reason: 'Not Yet Implemented');
        expect(notifMap['user'], testUser.username);
      });
      test('Gets Marked as read', () {
        // TODO: Unit Test
      });
      test('Generates a timestamp', () {
        var notification = Notification();
        expect(notification.timestamp, isNotNull);
      });
    });
  });
}
