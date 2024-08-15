import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<void> requestPermissions() async {
    await [
      Permission.microphone,
      Permission.camera,
    ].request();
  }
}
