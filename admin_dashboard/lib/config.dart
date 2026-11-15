/// Server address used by the whole app.
///
/// To change it without editing code:
///   flutter run --dart-define=API_HOST=10.0.2.2       (Android emulator)
///   flutter run --dart-define=API_HOST=192.168.1.20   (real phone: your PC's IP)
/// The default 127.0.0.1 works for web / Windows on the same PC.
class AppConfig {
  static const String host =
      String.fromEnvironment('API_HOST', defaultValue: '127.0.0.1');

  static const String apiUrl = 'http://$host:8000';

  static const String wsUrl = 'ws://$host:8000';
}