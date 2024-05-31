import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///Detects app states
class LifeCycleHandler extends WidgetsBindingObserver{
  final AsyncCallback resumenCallBack;

  LifeCycleHandler({required this.resumenCallBack});

  @override
  ///Detects app state. It can be [inactive], [detached], [hidden], [paused], [resumed]
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