import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  static final UserProvider _instance = UserProvider._internal();

  factory UserProvider() {
    return _instance;
  }

  UserProvider._internal();

  String _userKey = '';

  String get userKey => _userKey;

  void setUserKey(String? newUserKey) {
    _userKey = newUserKey!;
    notifyListeners();
  }
}
