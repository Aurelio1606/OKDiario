import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LifeCycleHandler extends WidgetsBindingObserver{
  final AsyncCallback resumenCallBack;

  LifeCycleHandler({required this.resumenCallBack});

  @override
  Future<Null> didChangeAppLifecycleState(AppLifecycleState state) async {

    switch (state){
        case AppLifecycleState.inactive:
        case AppLifecycleState.detached:
        case AppLifecycleState.hidden:
        case AppLifecycleState.paused:
        case AppLifecycleState.resumed:
          await resumenCallBack();
          break;
    }
    
  }
}