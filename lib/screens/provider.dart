import 'package:flutter/material.dart';

///Allows us to userKey in the app context, saving it.
class UserProvider extends ChangeNotifier {
  static final UserProvider _instance = UserProvider._internal();

  factory UserProvider() {
    return _instance;
  }

  UserProvider._internal();

  String _userKey = '';

  ///Returns the userKey
  String get userKey => _userKey;

  ///Saves the userKey [newUserKey]
  void setUserKey(String? newUserKey) {
    _userKey = newUserKey!;
    notifyListeners();
  }
}
