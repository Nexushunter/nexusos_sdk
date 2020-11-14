import 'package:flutter_test/flutter_test.dart';
import 'package:nexusos_sdk/nexusos_sdk.dart' as sys;

void main() {
  group('NotificationManager', () {
    group('Fails When', () {
      sys.NotificationManager nm;
      sys.User user;
      sys.Notification notification;
      setUpAll(() {
        nm = sys.NotificationManager();
        user = sys.User(
            username: 'user1',
            password: sys.EncryptedString(toEncrypt: 'testing1'));
        notification = sys.Notification(title: 'Test', message: 'Unit test');
      });
      test('No current user/user on notification', () {
        bool succeeded = nm.create(notification);
        expect(succeeded, isFalse);
      });
    });
    group('Defaults', () {
      sys.NotificationManager nm;
      sys.User user;
      sys.Notification notification;
      setUpAll(() {
        nm = sys.NotificationManager();
        user = sys.User(
            username: 'user1',
            password: sys.EncryptedString(toEncrypt: 'testing1'));
        notification =
            sys.Notification(title: 'Test', message: 'Unit test', user: user);
      });
      test('Empty Pending', () {
        expect(nm.pending, isEmpty);
        expect(nm.allExternalPending, isEmpty);
      });

      test('Clears pending', () {
        nm.currentUser = user;
        nm.create(notification);
        expect(nm.pending.length, 1);
        nm.clear();
        expect(nm.pending.length, 0);
      });

      test('Receives a notification', () async {
        nm.currentUser = user;
        expect(await nm.pendingNotifications.isEmpty, isTrue);
        nm.create(notification);
        expect(await nm.pendingNotifications.length, 1);
      });
    });
  });
}
