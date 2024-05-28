import 'package:flutter/material.dart';

class SnackBarService {
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  void showSnackBar({required String content}) {
    scaffoldKey.currentState?.showSnackBar(SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(content),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void showTopSnackBar(
      {required String content, required double size}) {
    scaffoldKey.currentState?.showSnackBar(SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(content),
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.up,
      margin: EdgeInsets.only(
          bottom: size - 150,
          left: 10,
          right: 10),
    ));
  }

  void removeSnackBar(){
    scaffoldKey.currentState!.removeCurrentSnackBar();
  }
}
