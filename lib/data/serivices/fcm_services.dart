import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Request permission (important for Android 13+ / iOS)
    await _firebaseMessaging.requestPermission();

    // Get device token
    await _firebaseMessaging.getToken();

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    });
  }
}