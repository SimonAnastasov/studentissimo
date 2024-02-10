// user_settings.dart
import 'package:flutter/foundation.dart';

// Singleton and Observer pattern
class UserSettings {
  static final UserSettings _singleton = UserSettings._internal();

  factory UserSettings() {
    return _singleton;
  }

  UserSettings._internal();

  String _name = '';
  final ValueNotifier<String> userNameNotifier = ValueNotifier<String>('');

  String get name => _name;

  set name(String value) {
    _name = value;
    userNameNotifier.value = value; // Notify listeners about the change
  }
}