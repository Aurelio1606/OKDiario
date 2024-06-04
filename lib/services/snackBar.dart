import 'package:flutter/material.dart';

class SnackBarService {
  final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  ///Shows a snack bar at the bottom of the screen with the text [content]
  void showSnackBar({required String content}) {
    scaffoldKey.currentState?.showSnackBar(SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(content),
      behavior: SnackBarBehavior.floating,
    ));
  }

  ///Shows a snack bar at the top of the screen with the text [content] and  
  ///the height [size] to place it in different parts of the screen 
  ///(it can change between devices)
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

  ///Deletes the snackbar
  void removeSnackBar(){
    scaffoldKey.currentState!.removeCurrentSnackBar();
  }
}
