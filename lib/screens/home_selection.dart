import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/screens/app_lifecycle.dart';
import 'package:proyecto/screens/home_estudent.dart';
import 'package:proyecto/screens/provider.dart';
import 'package:proyecto/screens/home_teacher.dart';
import 'package:proyecto/services/operations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeSelection extends StatefulWidget {
  const HomeSelection({super.key});

  @override
  State<HomeSelection> createState() => _HomeSelectionState();
}

class _HomeSelectionState extends State<HomeSelection> {
  String? userType;

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Titulo: ${message.notification?.title}');
  }

  @override
  void initState() {
    super.initState();
    //NotificationProvider notificationProvider = NotificationProvider();
    //notificationProvider.initNotifications();

    WidgetsBinding.instance.addObserver(
        LifeCycleHandler(resumenCallBack: () async => _refreshContent()));

    checkHour();
    //getToken();
    //updateDependencies();

    getUserType().then((results) {
      setState(() {
        if (results != null) {
          userType = results;
        }
      });
    });
    //FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  // void updateDependencies() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   PackageInfo packageInfo = await PackageInfo.fromPlatform();

  //   String version = packageInfo.version;
  //   String lastVersion = prefs.getString('Version') ?? version;

  //   if (lastVersion != version) {
  //     print("Actualizamos shared preferences");
  //     print("version $version");
  //     print("version $lastVersion");
  //     prefs.setString('Version', version);
  //   } else {
  //     print("No actualiazamons");
  //     print("version $version");
  //     print("version $lastVersion");
  //     prefs.setString('Version', version);
  //   }
  // }

  // void getToken() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool subscrito = prefs.getBool('subscrito') ?? false;
  //   if (!subscrito) {
  //     final fcmToken = await FirebaseMessaging.instance.getToken();
  //     //await FirebaseMessaging.instance.subscribeToTopic("Recordatorio");
  //     await FirebaseMessaging.instance
  //         .subscribeToTopic("RecordatorioPollSemana");
  //     await FirebaseMessaging.instance
  //         .subscribeToTopic("RecordatorioPollViernes");
  //     prefs.setBool('subscrito', true);
  //     print(fcmToken);
  //   }
  // }

  void _refreshContent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool show = prefs.getBool('Shown') ?? false;
    int horas = prefs.getInt('Horas') ?? 18;
    int minutos = prefs.getInt('Minutos') ?? 00;

    var now = DateTime.now();
    DateTime lastDate = DateTime(
      now.year,
      prefs.getInt('Mes') ?? now.month,
      prefs.getInt('Dia') ?? now.day,
    );

    if (DateTime(2024, now.month, now.day)
        .isAfter(DateTime(2024, lastDate.month, lastDate.day))) {
      prefs.setBool('Shown', false);
      prefs.setInt('Mes', now.month);
      prefs.setInt('Dia', now.day);
    }

    if (this.mounted) {
      //Comprobar si sigue funcionando
      setState(() {
        var pollDateInterval1 =
            DateTime(2024, now.month, now.day, horas, minutos);
        var pollDateInterval2 =
            DateTime(2024, now.month, now.day, horas, minutos + 30);

        print(show);
        print(minutos);
        if (!show) {
          if (now.weekday != DateTime.saturday &&
              now.weekday != DateTime.sunday) {
            if (now.isAfter(pollDateInterval1)) {
              if (now.isBefore(pollDateInterval2)) {
                Future.delayed(Duration(seconds: 2), () {
                  //showStateDialog(context, now);
                });

                print("Aqui");
                prefs.setBool('Shown', true);
              }
            }
          }
        }
      });
    }
  }

  checkHour() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool show = prefs.getBool('Shown') ?? false;
    int horas = prefs.getInt('Horas') ?? 18;
    int minutos = prefs.getInt('Minutos') ?? 00;

    var now = DateTime.now();
    DateTime lastDate = DateTime(
      now.year,
      prefs.getInt('Mes') ?? now.month,
      prefs.getInt('Dia') ?? now.day,
    );

    // print("Primero ${DateTime(2024, now.month, now.day)}");
    // print("Segundo ${DateTime(2024, lastDate.month, lastDate.day)}");

    // print(prefs.getInt('Mes') ?? now.month);
    // print(prefs.getInt('Dia') ?? now.day);
    // print(lastDate);

    // print(DateTime(2024, lastDate.month, lastDate.day-1));
    // print(DateTime(2024, now.month, now.day)
    //     .isAfter(DateTime(2024, lastDate.month, lastDate.day)));

    if (DateTime(2024, now.month, now.day)
        .isAfter(DateTime(2024, lastDate.month, lastDate.day))) {
      prefs.setBool('Shown', false);
      prefs.setInt('Mes', now.month);
      prefs.setInt('Dia', now.day);
    }

    print(horas);
    print(show);
    print(minutos);
    if (!show) {
      var pollDateInterval1 =
          DateTime(2024, now.month, now.day, horas, minutos);
      var pollDateInterval2 =
          DateTime(2024, now.month, now.day, horas, minutos + 30);

      print(now);
      print("INtervalor 1 $pollDateInterval1");
      print(pollDateInterval2);

      if (now.weekday != DateTime.saturday && now.weekday != DateTime.sunday) {
        if (now.isAfter(pollDateInterval1)) {
          if (now.isBefore(pollDateInterval2)) {
            Future.delayed(Duration(seconds: 2), () {
              //showStateDialog(context, now);
            });
            print("Aqui");
            prefs.setBool('Shown', true);
            //show = true;
          }
        }
      }
    }
  }

  getUserType() async {
    UserProvider userProvider = UserProvider();
    String? user = await getUser(userProvider.userKey);
    final DatabaseReference _userType = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userProvider.userKey)
        .child("TipoUsuario");

    DataSnapshot snapshot = await _userType.get();
    print(snapshot.value.toString());

    return snapshot.value.toString();
  }
  // @override
  // void dispose() {
  //   super.dispose();
  //   timer?.cancel();
  // }

  @override
  Widget build(BuildContext context) {
    if (userType == null) {
      //Espera hasta que carga el usuario
      return Center(
        child: Container(),
      );
    }

    if (userType == 'admin') {
      return TeacherView();
    } else {
      return StudentView();
    }
  }
}
