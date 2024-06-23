import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/screens/app_lifecycle.dart';
import 'package:proyecto/screens/home_estudent.dart';
import 'package:proyecto/screens/provider.dart';
import 'package:proyecto/screens/home_teacher.dart';
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

    WidgetsBinding.instance.addObserver(
        LifeCycleHandler(resumenCallBack: () async => _refreshContent()));

    checkHour();

    getUserType().then((results) {
      setState(() {
        if (results != null) {
          userType = results;
        }
      });
    });
  }

  ///When the app is opened after being closed or minimized, this function compares the current hour with
  ///the hour and minutes the user's device has stored to show an alert.
  void _refreshContent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool show = prefs.getBool('Shown') ?? false;
    int hours = prefs.getInt('Horas') ?? 18;
    int minutes = prefs.getInt('Minutos') ?? 00;

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
            DateTime(2024, now.month, now.day, hours, minutes);
        var pollDateInterval2 =
            DateTime(2024, now.month, now.day, hours, minutes + 30);

        //if the alert has not yet been shown, if it is not the weekend and the current hour is bigger than or equal
        //to the one stored in the device, the alert is shown
        if (!show) {
          if (now.weekday != DateTime.saturday &&
              now.weekday != DateTime.sunday) {
            if (now.isAfter(pollDateInterval1)) {
              if (now.isBefore(pollDateInterval2)) {
                Future.delayed(const Duration(seconds: 2), () {
                  //showStateDialog(context, now);
                });

                prefs.setBool('Shown', true);
              }
            }
          }
        }
      });
    }
  }

  ///This function checks current hour with the one stored in the device, such as function _refreshContent(). 
  ///The difference is this function is called when the user changes between pages in the app 
  checkHour() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool show = prefs.getBool('Shown') ?? false;
    int hours = prefs.getInt('Horas') ?? 18;
    int minutes = prefs.getInt('Minutos') ?? 00;

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

    //if the alert has not yet been shown, if it is not the weekend and the current hour is bigger than or equal
    //to the one stored in the device, the alert is shown
    if (!show) {
      var pollDateInterval1 =
          DateTime(2024, now.month, now.day, hours, minutes);
      var pollDateInterval2 =
          DateTime(2024, now.month, now.day, hours, minutes + 30);

      if (now.weekday != DateTime.saturday && now.weekday != DateTime.sunday) {
        if (now.isAfter(pollDateInterval1)) {
          if (now.isBefore(pollDateInterval2)) {
            Future.delayed(Duration(seconds: 2), () {
              //showStateDialog(context, now);
            });
            prefs.setBool('Shown', true);
          }
        }
      }
    }
  }

  ///Gets user type (admin, student) from the database and returns it
  getUserType() async {
    UserProvider userProvider = UserProvider();
    final DatabaseReference _userType = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userProvider.userKey)
        .child("TipoUsuario");

    DataSnapshot snapshot = await _userType.get();

    return snapshot.value.toString();
  }

  @override
  //Depending on the user type, it returns the student or admin view
  Widget build(BuildContext context) {
    if (userType == null) {
      //waits until userType is ready
      return Center(
        child: Container(),
      );
    }

    if (userType == 'admin') {
      return const TeacherView();
    } else {
      return const StudentView();
    }
  }
}
