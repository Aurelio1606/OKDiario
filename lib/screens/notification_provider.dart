import 'package:flutter/material.dart';
import 'package:proyecto/services/notifications.dart';

class NotificationProvider extends ChangeNotifier {
  static final NotificationProvider _instance =
      NotificationProvider._internal();

  factory NotificationProvider() {
    return _instance;
  }

  NotificationProvider._internal();

  void setNewNotification(DateTime actual) {
    //var scheduleNot = actual.add(Duration(hours: 1));
    NotificationService().scheduleNotification(
      id: 1,
      title: '¿Como te encuentras hoy?',
      body: actual.weekday == DateTime.friday 
      ? '¡Recuerda completar el Resumen de la semana!'
      : '¡Recuerda completar el Diario de aprendizaje!',
      scheduledNoti: actual,
    );
  }

  void initNotifications() {
    var first = DateTime.now();
    var scheduleNot = DateTime(2024, first.month, first.day, 18, 00);
    NotificationService().periodicDailyNotification(
      id: 1,
      title: '¿Como te encuentras hoy?',
      body: '¡Recuerda completar el Diario de aprendizaje!',
      scheduledNoti: scheduleNot,
    );
  }
}
