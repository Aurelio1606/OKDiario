import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/screens/avatar.dart';
import 'package:proyecto/screens/notification_provider.dart';
import 'package:proyecto/screens/provider.dart';
import 'package:proyecto/screens/questions.dart';
import 'package:proyecto/services/notifications.dart';
import 'package:proyecto/services/operations.dart';
import 'package:proyecto/widgets/widget_top_homeStudent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

String question = "";
Color? color;
List<String> respuestas = [];
Query? answers;
String questionType = "";
String questionKey = "";
int totalPuntuation = 0;
int dayPoints = 0;
int globalPuntuation = 0;
String writenField = "";
int? testField;
List<int?> indexField = [];
bool questionComplete = false;

class StudentView extends StatefulWidget {
  /// Current page
  final int page;

  const StudentView({super.key, this.page = 0});
  @override
  _StudentView createState() => _StudentView();
}

///Class that displays student view on the app
class _StudentView extends State<StudentView> {
  ///Current page 
  int currentPageIndex = 0;
  ///List of colors
  List<Color> colorList = <Color>[];
  PageController? _pageController;
  late final List<Widget Function()> _widgetOptions;
  ///Number of points user has earned at a certain day
  int dailyPoints = 0;
  ///Number of points user has 
  int totalPoints = 0;
  ///Number of points user has earnead overall
  int globalPoints = 0;
  int numQuestions = 0;
  ///Wether a question is completed or not
  bool completed = false;
  ///Actual strike from user
  int racha = 0;
  ///List of today achivements
  List<Map<dynamic, dynamic>> todayAchivements = [];

  @override
  void initState() {
    colorList.add(Color.fromARGB(255, 160, 122, 192));
    colorList.add(Color.fromARGB(255, 225, 220, 130));
    colorList.add(Color.fromARGB(255, 126, 150, 218));
    colorList.add(Color.fromARGB(255, 241, 165, 206));
    colorList.add(Color.fromARGB(255, 196, 112, 112));
    colorList.add(Color.fromARGB(255, 201, 202, 101));
    colorList.add(Color.fromARGB(255, 112, 204, 112));
    colorList.add(Color.fromARGB(255, 242, 145, 145));
    colorList.add(Color.fromARGB(255, 133, 129, 129));

    //getToken();
    updateDependencies();

    _pageController = PageController(initialPage: widget.page);
    currentPageIndex = widget.page;

    _widgetOptions = [
      () => homePage(context),
      () => ranking(context),
      () => profile(context),
      () => progress(context),
    ];

    indexField.clear(); //para borrar la seleccion de la respuesta del circulo
    writenField = "";

    super.initState();
  }

  @override
  void dispose() {
    _pageController!.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      currentPageIndex = index;
      // _pageController!.animateToPage(index,
      //     duration: Duration(milliseconds: 700), curve: Curves.easeInOut);
      _pageController!.jumpToPage(index);
    });
  }

  ///Update user notifications if app version changes
  void updateDependencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    String lastVersion = prefs.getString('Version') ?? "1.0";

    if (lastVersion != version) {
      print("Actualizamos shared preferences");
      print("version $version");
      print("version $lastVersion");
      prefs.setBool('subscrito', false);
      prefs.setString('Version', version);
      getToken();
    } else {
      print("No actualiazamons");
      print("version $version");
      print("version $lastVersion");
      prefs.setString('Version', version);
    }
  }

  ///Checks if user is subscribed, if not, user is subscribe to the topics
  void getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool subscrito = prefs.getBool('subscrito') ?? false;
    if (!subscrito) {
      await FirebaseMessaging.instance.subscribeToTopic("RecordatorioManana");
      await FirebaseMessaging.instance.subscribeToTopic("RecordatorioTarde");
      await FirebaseMessaging.instance.subscribeToTopic("RecordatorioNoche");
      prefs.setBool('subscrito', true);
      
    }
  }

  ///Calculates actual week number
  int getWeekNumber() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, 1, 1);

    DateTime from = DateTime.utc(firstDay.year, firstDay.month, firstDay.day);
    DateTime to = DateTime.utc(now.year, now.month, now.day);
    return ((to.difference(from).inDays + firstDay.weekday) / 7).ceil();
  }

  ///Gets user's dailyPoints from database
  getPuntos(String userKey) async {
    final DatabaseReference _dailyPoints = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey)
        .child("InfoRespuestas")
        .child(DateTime.now().month.toString())
        .child(getWeekNumber().toString())
        .child(DateTime.now().weekday.toString());

    DataSnapshot puntuacion = await _dailyPoints.get();
    if (puntuacion.value != null) {
      dailyPoints = (puntuacion.value as Map)["Puntos"];
    } else {
      dailyPoints = 0;
    }
  }

  ///Gets actual user's puntuation from database
  getPuntosTotales(String userKey) async {

    final DatabaseReference _totalPoints = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey);

    DataSnapshot puntuacion = await _totalPoints.get();
    if (puntuacion.value != null) {
      if ((puntuacion.value as Map)["PuntosTotal"] != null) {
        totalPoints = (puntuacion.value as Map)["PuntosTotal"];
      } else {
        totalPoints = 0;
      }
    } else {
      totalPoints = 0;
    }
  }

  ///Gets points user has earned overall from database
  getGlobalPuntuation(String userKey) async {
    final DatabaseReference _globalPoints = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey)
        .child("PuntosGlobales");

    DataSnapshot snapshot = await _globalPoints.get();

    if (snapshot.exists) {
      if (snapshot.value != null) {
        globalPoints = snapshot.value as int;
      } else {
        globalPoints = 0;
      }
    } else {
      globalPoints = 0;
    }
  }

  ///Initializes parameters and gets the question title [questionArg], its color [colorArg],
  ///totalPuntuation from user [totalPuntuationArg], the daily puntuation [dayPointsArg],
  ///the global puntuation [globalPointsArg], the type os the question [questionTypeArg] and
  ///its key [questionKeyArg]
  initializeParameters(
      String questionArg,
      Color? colorArg,
      int totalPuntuationArg,
      int dayPointsArg,
      int globalPointsArg,
      Query answersArg,
      String questionTypeArg,
      String questionKeyArg) {
    
    question = questionArg;
    color = colorArg;

    totalPuntuation = totalPuntuationArg;
    dayPoints = dayPointsArg;
    globalPuntuation = globalPointsArg;
    answers = answersArg;
    questionType = questionTypeArg;
    questionKey = questionKeyArg;
  }

  ///Gets the answers from user's to a certain question if it's completed
  getAnswers(String userKey, String questionKey, bool complete) async {
    final DatabaseReference _savedAnswer = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey)
        .child("InfoRespuestas")
        .child(DateTime.now().month.toString())
        .child(getWeekNumber().toString())
        .child(DateTime.now().weekday.toString())
        .child(questionKey);

    DataSnapshot snapshot = await _savedAnswer.get();
    if (complete) {
      if (snapshot.value != null) {
        if ((snapshot.value as Map)['RespuestaEscrita'] != null) {
          writenField = (snapshot.value as Map)['RespuestaEscrita'];
        }
        if ((snapshot.value as Map)['Indice'] is List) {
          (snapshot.value as Map)['Indice'].forEach((key) {
            indexField.add(key);
          });
          //indexField = (snapshot.value as Map)['Indice'].toList();
        } else {
          testField = (snapshot.value as Map)['Indice'];
        }
      }
      questionComplete = complete;
    } else {
      //writenField = "";
      testField = null;
      questionComplete = complete;
    }
  }

  ///Checks the number of points a user has earned in a week and returns positive feedback according to user points
  Widget testTendencie(Map puntos) {
    //! Arreglar return
    List<double> differences = [];

    if (puntos.length >= 2) {
      for (int i = 1; i < puntos.values.length && i < 6; i++) {
        differences
            .add(puntos.values.elementAt(i) - puntos.values.elementAt(i - 1));
      }

      double sumDifferences = differences.reduce((x, y) => x + y);
      bool better = sumDifferences > 0;
      bool worse = sumDifferences < 0;

      if (better) {
        return Column(
          children: [
            const Text(
              '¡Has mejorado mucho!',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/confeti.png',
                  width: 60,
                  height: 60,
                ),
                const SizedBox(
                  width: 40,
                ),
                const Text("¡Sigue así!", style: TextStyle(fontSize: 20)),
                const SizedBox(
                  width: 40,
                ),
                Image.asset(
                  'assets/images/confeti.png',
                  width: 60,
                  height: 60,
                ),
              ],
            ),
            const SizedBox(
              width: 20,
            ),
            Image.asset(
              'assets/images/celebracion.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(
              height: 40,
            ),
          ],
        );
        // return '¡Has mejorado mucho!';
      }

      if (worse) {
        if (puntos.values.last >
            puntos.values.elementAt(puntos.values.length - 2)) {
          return Column(
            children: [
              const Text(
                'Puedes mejorar más.',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/confeti.png',
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  const Text("¡Ánimo!", style: TextStyle(fontSize: 20)),
                  const SizedBox(
                    width: 40,
                  ),
                  Image.asset(
                    'assets/images/confeti.png',
                    width: 60,
                    height: 60,
                  ),
                ],
              ),
              const SizedBox(
                width: 20,
              ),
              Image.asset(
                'assets/images/celebracion.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(
                height: 40,
              ),
            ],
          );
          // return 'Puedes mejorar más. Ánimo';
        } else {
          return Column(
            children: [
              const Text(
                'Necesitas un poco esforzarte más.',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/confeti.png',
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  const Text("¡Tú puedes!", style: TextStyle(fontSize: 20)),
                  const SizedBox(
                    width: 40,
                  ),
                  Image.asset(
                    'assets/images/confeti.png',
                    width: 60,
                    height: 60,
                  ),
                ],
              ),
              const SizedBox(
                width: 20,
              ),
              Image.asset(
                'assets/images/celebracion.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(
                height: 40,
              ),
            ],
          );
          //return 'Necesitas esforzarte más';
        }
      }

      return Column(
        children: [
          const Text(
            'Puedes esforzarte un poquito más.',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/confeti.png',
                width: 60,
                height: 60,
              ),
              const SizedBox(
                width: 40,
              ),
              const Text("¡Ánimo!", style: TextStyle(fontSize: 20)),
              const SizedBox(
                width: 40,
              ),
              Image.asset(
                'assets/images/confeti.png',
                width: 60,
                height: 60,
              ),
            ],
          ),
          const SizedBox(
            width: 20,
          ),
          Image.asset(
            'assets/images/celebracion.png',
            width: 150,
            height: 150,
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      );
      //return 'Puedes esforzarte un poquito más. Ánimo';
    } else if (puntos.length == 1 && puntos.values.first != 0) {
      return Column(
        children: [
          const Text(
            '¡Muy bien, has conseguido tus primeros puntos!',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/confeti.png',
                width: 60,
                height: 60,
              ),
              const SizedBox(
                width: 40,
              ),
              const Text("¡Sigue así!", style: TextStyle(fontSize: 20)),
              const SizedBox(
                width: 40,
              ),
              Image.asset(
                'assets/images/confeti.png',
                width: 60,
                height: 60,
              ),
            ],
          ),
          const SizedBox(
            width: 20,
          ),
          Image.asset(
            'assets/images/celebracion.png',
            width: 150,
            height: 150,
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          const Text(
            'Completa preguntas y logros para ver tu progreso.',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/confeti.png',
                width: 60,
                height: 60,
              ),
              const SizedBox(
                width: 40,
              ),
              const Text("¡Ánimo!", style: TextStyle(fontSize: 20)),
              const SizedBox(
                width: 40,
              ),
              Image.asset(
                'assets/images/confeti.png',
                width: 60,
                height: 60,
              ),
            ],
          ),
          const SizedBox(
            width: 20,
          ),
          Image.asset(
            'assets/images/celebracion.png',
            width: 150,
            height: 150,
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      );
      //return 'Completa preguntas y logros para ver tu progreso. !Ánimo!';
    }
  }

  ///Checks if a question should be available according to the hour
  int checkQuestion(int hour, int questionKey) {

    int hour1 = 15;
    int hour2 = 18;

    if (questionKey >= 10 && questionKey < 30 && hour < 15) {
      return hour1;
    } else if (questionKey >= 30 && hour < 18) {
      return hour2;
    } else {
      return 0;
    }
  }

//!Comprobar con questions, funciones repetidas!//

  updateGlobalPoints(String userKey, int updatePoints) async {
    final DatabaseReference _globalPoints = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey);

    _globalPoints.update({
      'PuntosGlobales': updatePoints,
    });
  }

  updatePuntosTotales(String userKey, int updatePoints) async {
    final DatabaseReference _updateTotalPoints = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey);

    _updateTotalPoints.update({
      'PuntosTotal': updatePoints,
    });
  }

  updatePuntos(String userKey, int updatePoints) async {
    final DatabaseReference _updateDailyPoints = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey)
        .child("InfoRespuestas")
        .child(DateTime.now().month.toString())
        .child(getWeekNumber().toString())
        .child(DateTime.now().weekday.toString());

    _updateDailyPoints.update({
      'Puntos': updatePoints,
    });
  }
//!-----------!//

  Future<bool> checkCompleteQuestion(
      String userKey, String questionNumber) async {
    final Query _checkComplete = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey)
        .child("InfoRespuestas")
        .child(DateTime.now().month.toString())
        .child(getWeekNumber().toString())
        .child(DateTime.now().weekday.toString());

    DataSnapshot questionsCompleted = await _checkComplete.get();
    if ((questionsCompleted.value as Map)[questionNumber] != null) {
      return true;
    } else {
      return false;
    }
  }

  updateRachaPoints(String userKey) async {
    getPuntos(userKey).then((_) {
      updatePuntos(userKey, dailyPoints + 50);
      setState(() {});
    });
    getPuntosTotales(userKey).then((_) {
      updatePuntosTotales(userKey, totalPoints + 50);
      setState(() {});
    });
    // await updatePuntos(userKey, dailyPoints + 50);
    // await updatePuntosTotales(userKey, totalPoints + 50);
  }

  getNumQuestions(Query userTasks) async {
    //Funcion para saber el numero de preguntas que hay en home page

    DataSnapshot tam = await userTasks.get();
    Map auxMap =
        {}; //Mapa auxiliar que solo uso para saber el numero de preguntas

    auxMap['respuesta'] = tam.value;
    auxMap['key'] = tam.key;

    numQuestions = (auxMap['respuesta'] as Map).length -
        1; //-1 para que al final se muestren los puntos
  }

  getRacha(String userKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var now = DateTime.now();
    DateTime rachaDate = DateTime(
      now.year,
      prefs.getInt('RachaMes') ?? now.month - 1,
      prefs.getInt('RachaDia') ?? now.day - 1,
    );

    //print(rachaDate);

    if (DateTime.now().day != rachaDate.day) {
      if (DateTime.now().day - 1 == rachaDate.day) {
        print("DIAS DISTINTOS");

        racha = prefs.getInt('Racha') ?? 0;
        prefs.setInt('Racha', racha += 1);
        prefs.setInt('RachaMes', now.month);
        prefs.setInt('RachaDia', now.day);
        racha = prefs.getInt('Racha') ?? 1;
        updateRachaPoints(userKey);
      } else {
        prefs.setInt('Racha', 1);
        prefs.setInt('RachaMes', now.month);
        prefs.setInt('RachaDia', now.day);
        racha = prefs.getInt('Racha') ?? 1;
      }
    } else {
      racha = prefs.getInt('Racha') ?? 1;

    }
  }

  getMaxRacha(String userKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final DatabaseReference _maxRacha = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey)
        .child("MaxRacha");

    DataSnapshot snapshot = await _maxRacha.get();
    //prefs.setInt('Racha', 2);
    if (snapshot.exists) {
      if ((prefs.getInt('Racha') ?? 1) >=
          int.parse(snapshot.value.toString())) {
        _maxRacha.set(prefs.getInt('Racha') ?? 1);
        return "Felicidades es tu mayor racha";
      } else {
        return "Tu máxima racha fue ${snapshot.value}.\n¡Intenta superarla!";
      }
    } else {
      _maxRacha.set(prefs.getInt('Racha') ?? 1);
      return "Felicidades es tu mayor racha";
    }
  }

  getAvatar(String userKey) async {
    final DatabaseReference _selectedAvatar = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey)
        .child("AvatarSeleccionado");

    DataSnapshot snapshot = await _selectedAvatar.get();

    return snapshot.value;
  }

  getLogros(String userKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var now = DateTime.now();

    // prefs.setInt('LogroMes', 4);
    // prefs.setInt('LogroDia', 5);

    DateTime achivementDate = DateTime(
      now.year,
      prefs.getInt('LogroMes') ?? now.month - 1,
      prefs.getInt('LogroDia') ?? now.day - 1,
    );

    if (achivementDate.day != now.day) {
      final Query _achivements = FirebaseDatabase(
              databaseURL:
                  "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
          .ref()
          .child("Usuarios2")
          .child("Logros");

      final DatabaseReference _todayAchivements = FirebaseDatabase(
              databaseURL:
                  "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
          .ref()
          .child("Usuarios2")
          .child("DatosUsuario")
          .child(userKey)
          .child("Logros");

      DataSnapshot snapshot = await _achivements.get();

      var randomInt = Random().nextInt((snapshot.value as List).length);

      //Limpiamos los logros diarios
      _todayAchivements.remove();

      //Añadimos el logro del dia
      _todayAchivements.push().set({
        'Logro': (snapshot.value as List).elementAt(randomInt)['Logro'],
        'Objetivo': (snapshot.value as List).elementAt(randomInt)['Objetivo'],
        'Id': randomInt,
      });

      print((snapshot.value as List).elementAt(randomInt));
      prefs.setInt('LogroDia', now.day);
      prefs.setInt('LogroMes', now.month);
    }
  }

  updateLogros(String userKey, BuildContext context) async {
    final DatabaseReference _achivements = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey)
        .child("Logros");

    DataSnapshot snapshot = await _achivements.get();

    //print("MAPA2 ${(snapshot.value as List).elementAt(0)}");
  }

  checkCompleteLogros(String userKey, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final DatabaseReference _todayAchivements = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey)
        .child("Logros");

    final Query _checkComplete = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey)
        .child("InfoRespuestas")
        .child(DateTime.now().month.toString())
        .child(getWeekNumber().toString())
        .child(DateTime.now().weekday.toString());

    DataSnapshot completeQuestions = await _checkComplete.get();

    DataSnapshot todayAchivements = await _todayAchivements.get();

    //print("La llave es ${(todayAchivements.value as Map).values.elementAt(0)['Id']}");

    DateTime now = DateTime.now();
    DateTime loginDate = DateTime(
      //-1 ya que si no guardaria el dia actual y no entraria en la condicion de abajo
      //y por lo tanto la fecha no se guardaría nunca y siempre seria la actual
      DateTime.now().year,
      prefs.getInt('LoginMes') ?? DateTime.now().month - 1,
      prefs.getInt('LoginDia') ?? DateTime.now().day - 1,
    );

    if (DateTime(now.year, now.month, now.day).isAfter(loginDate)) {
      prefs.setInt('NumLogins', 0);
      prefs.setInt('LoginMes', now.month);
      prefs.setInt('LoginDia', now.day);
      prefs.setBool('LogroShown', false);
      prefs.setBool('LoginShown', false);
    }

    bool shown = prefs.getBool('LogroShown') ?? false;
    bool shownLogins = prefs.getBool('LoginShown') ?? false;

    //  prefs.setBool('LoginShown', false);
    //   prefs.setInt('NumLogins', 2);

    //prefs.setBool('LogroShown', false);

    if (todayAchivements.value != null) {
      switch ((todayAchivements.value as Map).values.elementAt(0)['Id']) {
        case 0:
          if (prefs.getInt('NumLogins') == 3 && !shownLogins) {
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              showCompleteAchivement(context);
            }

            print("dayPoints ${dayPoints + 100}");
            print("totaL ${totalPoints + 100}");

            updatePuntos(userKey, dailyPoints + 100);
            updatePuntosTotales(userKey, totalPoints + 100);
            updateGlobalPoints(userKey, globalPoints + 100);
            prefs.setBool('LoginShown', true);
            setState(() {
              dailyPoints += 100;
              totalPoints += 100;
            });
          }
          break;
        case 1:
          if (completeQuestions.exists) {
            if ((completeQuestions.value as Map).length - 1 == 6 && !shown) {
              await Future.delayed(const Duration(milliseconds: 500));
              if (mounted) {
                showCompleteAchivement(context);
              }
              updatePuntos(userKey, dailyPoints + 100);
              updatePuntosTotales(userKey, totalPoints + 100);
              updateGlobalPoints(userKey, globalPoints + 100);
              prefs.setBool('LogroShown', true);

              setState(() {
                dailyPoints += 100;
                totalPoints += 100;
              });
            }
          }
          break;

        default:
          print("No existe ese logro");
      }
    }
  }

  getPointsChart(String userKey) async {
    final List<int> puntos = [];
    final Query _points = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey)
        .child("InfoRespuestas")
        .child(DateTime.now().month.toString())
        .child(getWeekNumber().toString());

    DataSnapshot snapshot = await _points.get();
    var maxKey = 0;
    int lastIteration = 0;

    if (snapshot.exists) {
      //Comprobamos que existe la semana
      /**
       * Si existe comprobamos si es una lista o un mapa, ya que
       * si los elementos tienen key discontinuas (1,3) de vuelve un mapa
       * en caso contrario (son continias 0,1,2) devuelve una lista
       */
      if (snapshot.value is List) {
        //print("lista");
        for (int i = 1; i < (snapshot.value as List).length && i < 6; i++) {
          //Para cada valor de la semana
          if ((snapshot.value as List).elementAt(i) != null) {
            //Si existe ese dia
            if ((snapshot.value as List).elementAt(i)['Puntos'] != null) {
              //Se comprueba si hay puntos
              puntos.add((snapshot.value as List).elementAt(i)['Puntos']);
              //print((snapshot.value as List).elementAt(i)['Puntos']);
            } else {
              print("No hay valor $i");
            }
          } else {
            puntos.add(0);
          }
        }
      } else {
        /**
         * si es un mapa guardo la key con mayor valor para iterar sobre todo el mapa
         */
        (snapshot.value as Map).forEach((key, value) {
          if (int.parse(key) > maxKey) {
            maxKey = int.parse(key);
          }
        });

        /**
         * para cada valor hasta maxKey, compruebo si i == key (Seria el dia)
         * si es igual añado los puntos en esa posicion y aumento la posicion del mapa en 1
         * si no añado 0
         */
        for (int i = 1; i <= maxKey && i < 6; i++) {
          //print("i: $i  mapa: ${(snapshot.value as Map).keys.elementAt(lastIteration)}");
          if (i ==
              int.parse(
                  (snapshot.value as Map).keys.elementAt(lastIteration))) {
            //print("aqui");
            puntos.add((snapshot.value as Map)
                .values
                .elementAt(lastIteration)['Puntos']);
            lastIteration++;
          } else {
            puntos.add(0);
          }
        }
      }
    } else {
      puntos.add(0);
    }

    return puntos;
  }

  Widget homePage(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final Query _userTasks = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("Preguntas");

    getPuntos(userProvider.userKey);
    getNumQuestions(_userTasks);
    getLogros(userProvider.userKey);
    updateLogros(userProvider.userKey, context);
    checkCompleteLogros(userProvider.userKey, context);

    //print("SEMANAAA ${getWeekNumber()}");

    MediaQueryData mediaQuery = MediaQuery.of(context);

    return Column(
      children: [
        Container(
          child: FutureBuilder(
              future: getPuntosTotales(userProvider.userKey),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                return Row(
                  children: [
                    //* Mi puntuacion
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: mediaQuery.size.width / 3,
                          child: const Text(
                            "Mi puntuacion",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                        const SizedBox(
                          height: 2.5,
                        ),
                        Row(
                          children: [
                            Text(
                              totalPoints.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 17),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Transform.translate(
                              offset: const Offset(0, -2),
                              child: Image.asset(
                                'assets/images/estrella.png',
                                width: 23,
                                height: 23,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),

                    //* Racha
                    FutureBuilder(
                        future: getRacha(userProvider.userKey),
                        builder: (context, AsyncSnapshot<dynamic> snapshot) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 3,
                                child: const Text(
                                  "Racha",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                              const SizedBox(
                                height: 2.5,
                              ),
                              Row(
                                children: [
                                  Text(
                                    racha.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Transform.translate(
                                    offset: const Offset(0, -2),
                                    child: Image.asset(
                                      'assets/images/racha.png',
                                      width: 23,
                                      height: 23,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),

                    //* Logros

                    GestureDetector(
                      onTap: () async {
                        _onItemTapped(2);
                        // print("object");
                        // await FirebaseMessaging.instance
                        //     .subscribeToTopic("prueba3");
                        //await NotificationService().checkPendingNotificationRequests(context);
                        // DateTime now = DateTime.now();
                        // DateTime noti =
                        //     DateTime(now.year, now.month, now.day, 18, 20);

                        // print("La hora es: ${noti.hour}");

                        // NotificationService().scheduleNotification(
                        //     id: 5,
                        //     title: 'Recuerda',
                        //     body:
                        //         'Ya puedes completar las preguntas y conseguir puntos',
                        //     scheduledNoti: noti);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 3,
                            child: const Text(
                              "Logros",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          const SizedBox(
                            height: 2.5,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 5,
                              ),
                              Transform.translate(
                                offset: const Offset(0, -2),
                                child: Image.asset(
                                  'assets/images/logros.png',
                                  width: 33,
                                  height: 33,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
        ),

        //*Dia

        Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 197, 197, 197),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Text(
            DateFormat('EEEE dd/MM/yyyy', 'es')
                .format(DateTime.now())
                .toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),

        //* Lista de preguntas
        Flexible(
          child: SingleChildScrollView(
            child: Container(
              color: Color.fromARGB(255, 245, 239, 216),
              //height: double.infinity,
              child: FirebaseAnimatedList(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  query: _userTasks,
                  itemBuilder: (BuildContext context, DataSnapshot snapshot,
                      Animation<double> animation, int index) {
                    Map tareas = snapshot.value as Map;
                    tareas['key'] = snapshot.key;

                    return FutureBuilder(
                      future: checkCompleteQuestion(
                          userProvider.userKey, tareas['key']),
                      builder: (context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        }

                        bool value = snapshot.data ?? false;
                        if (index < numQuestions) {
                          return listQuestions(
                              tareas: tareas,
                              complete: value,
                              puntos: totalPoints,
                              userKey: userProvider.userKey);
                        } else {
                          return Column(
                            children: [
                              listQuestions(
                                  tareas: tareas,
                                  complete: value,
                                  puntos: totalPoints,
                                  userKey: userProvider.userKey),
                              const SizedBox(
                                height: 20,
                              ),

                              //Puntuacion diaria
                              Container(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 40,
                                        ),
                                        Text(
                                          "Hoy has conseguido $dailyPoints",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Transform.translate(
                                          offset: Offset(0, -3),
                                          child: Image.asset(
                                            'assets/images/estrella.png',
                                            width: 30,
                                            height: 30,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    dailyPoints > 0
                                        ? const Text(
                                            "¡Vas muy bien, sigue así!",
                                            style: TextStyle(fontSize: 18),
                                            textAlign: TextAlign.center,
                                          )
                                        : const Text(
                                            "¡No te preocupes!\nCompleta una pregunta para conseguir puntos.",
                                            style: TextStyle(fontSize: 18),
                                            textAlign: TextAlign.center,
                                          ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    );
                  }),
            ),
          ),
        ),
      ],
    );
  }

  Widget ranking(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    String text() {
      if (globalPoints < 1000) {
        return "Consigue más puntos para obetener la siguiente medalla.";
      } else if (globalPoints >= 1000 && globalPoints < 3000) {
        return "¡Ánimo, ya estas cerca de la siguiente medalla!";
      } else if (globalPoints >= 3000 && globalPoints < 4000) {
        return "¡Ánimo, te queda muy poco para la medalla de plata!";
      } else if (globalPoints >= 4000 && globalPoints < 6000) {
        return "¡Felicidades, ya tienes la medalla de plata. Consigue más puntos para obtener la de oro";
      } else if (globalPoints >= 6000 && globalPoints < 8000) {
        return "¡Lo estas haciendo muy bien! Ya te queda poco para tener la medalla de oro";
      } else if (globalPoints >= 8000 && globalPoints < 12000) {
        return "¡Enhorabuena! Ya tienes la medalla de oro. ¡Intenta obetener la máxima puntuación!";
      } else if (globalPoints == 12000) {
        return "Felicidades! Has obtenido la máxima puntución. ¡Sigue así!";
      } else {
        return "Felicidades! Has superado la máxima puntución. ¡Lo estas haciendo genial!";
      }
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 76, 138, 189),
              border: Border.all(width: 1, color: Colors.black),
            ),
            height: 80,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 105,
                ),
                const Text(
                  "Ranking",
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  width: 10,
                ),
                Image.asset(
                  'assets/images/copa.png',
                  width: 45,
                  height: 45,
                ),
                const SizedBox(
                  width: 60,
                ),
                GestureDetector(
                  onTap: () {
                    showInfo(context, 2, globalPoints);
                  },
                  child: const Icon(
                    Icons.info_outline,
                    size: 40,
                  ),
                )
              ],
            ),
          ),
          FutureBuilder(
              future: getGlobalPuntuation(userProvider.userKey),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                print(globalPoints);
                return Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    globalPoints < 4000
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Image.asset(
                                'assets/images/medallaBronce.png',
                                width: 200,
                                height: 200,
                              ),
                              const Icon(
                                Icons.double_arrow_rounded,
                                size: 30,
                              ),
                              Image.asset(
                                'assets/images/medallaPlata.png',
                                width: 80,
                                height: 80,
                                opacity: const AlwaysStoppedAnimation(.5),
                              ),
                            ],
                          )
                        : globalPoints >= 4000 && globalPoints < 8000
                            ? SingleChildScrollView(
                                reverse: true,
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/medallaBronce.png',
                                      width: 80,
                                      height: 80,
                                      opacity: const AlwaysStoppedAnimation(.5),
                                    ),
                                    Transform.rotate(
                                      angle: pi,
                                      child: const Icon(
                                        Icons.double_arrow_rounded,
                                        size: 30,
                                      ),
                                    ),
                                    Image.asset(
                                      'assets/images/medallaPlata.png',
                                      width: 200,
                                      height: 200,
                                    ),
                                    const Icon(
                                      Icons.double_arrow_rounded,
                                      size: 30,
                                    ),
                                    Image.asset(
                                      'assets/images/medallaOro.png',
                                      width: 80,
                                      height: 80,
                                      opacity: const AlwaysStoppedAnimation(.5),
                                    ),
                                  ],
                                ),
                              )
                            : Row(
                                children: [
                                  Image.asset(
                                    'assets/images/medallaPlata.png',
                                    width: 80,
                                    height: 80,
                                    opacity: const AlwaysStoppedAnimation(.5),
                                  ),
                                  Transform.rotate(
                                    angle: pi,
                                    child: const Icon(
                                      Icons.double_arrow_rounded,
                                      size: 30,
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/images/medallaOro.png',
                                    width: 200,
                                    height: 200,
                                  ),
                                ],
                              ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 30,
                        ),
                        globalPoints < 4000
                            ? Text(
                                "$globalPoints de 4000",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              )
                            : globalPoints >= 4000 && globalPoints < 8000
                                ? Text(
                                    "$globalPoints de 8000",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  )
                                : Text(
                                    "$globalPoints de 12000",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                        Transform.translate(
                          offset: Offset(3, -4),
                          child: Image.asset(
                            'assets/images/estrella.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        text(),
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              }),
        ],
      ),
    );
  }

  Widget profile(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final Query _userAchivements = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userProvider.userKey)
        .child("Logros");

    int? currentSelected;

    Future<Widget> getAchivementObjective(String id, int objetivo) async {
      final Query _checkComplete = FirebaseDatabase(
              databaseURL:
                  "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
          .ref()
          .child("Usuarios2")
          .child("DatosUsuario")
          .child(userProvider.userKey)
          .child("InfoRespuestas")
          .child(DateTime.now().month.toString())
          .child(getWeekNumber().toString())
          .child(DateTime.now().weekday.toString());

      DataSnapshot completeQuestions = await _checkComplete.get();

      String objective = "";
      SharedPreferences prefs = await SharedPreferences.getInstance();
      DateTime now = DateTime.now();
      DateTime loginDate = DateTime(
        //-1 ya que si no guardaria el dia actual y no entraria en la condicion de abajo
        //y por lo tanto la fecha no se guardaría nunca y siempre seria la actual
        DateTime.now().year,
        prefs.getInt('LoginMes') ?? DateTime.now().month - 1,
        prefs.getInt('LoginDia') ?? DateTime.now().day - 1,
      );

      if (DateTime(now.year, now.month, now.day).isAfter(loginDate)) {
        prefs.setInt('NumLogins', 1);
        prefs.setInt('LoginMes', now.month);
        prefs.setInt('LoginDia', now.day);
        prefs.setBool('LogroShown', false);
        prefs.setBool('LoginShown', false);
      }

      Widget finalWidget = Container();

      switch (id) {
        case "0": //Logro num inicios de sesion
          if (prefs.getInt('NumLogins')! < objetivo) {
            objective = "${prefs.getInt('NumLogins')}/$objetivo";
            finalWidget = Text(
              objective,
              style: const TextStyle(fontSize: 16),
            );
          } else if (prefs.getInt('NumLogins')! >= objetivo) {
            objective = "${prefs.getInt('NumLogins')}/$objetivo";
            finalWidget = Row(
              children: [
                Text(
                  objective,
                  style: const TextStyle(fontSize: 16),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 2),
                  child: Image.asset(
                    'assets/images/completada.png',
                    width: 30,
                    height: 30,
                  ),
                ),
              ],
            );
          }
          break;
        case "1": //Logro preguntas completadas
          if (completeQuestions.value != null) {
            //Si hay datos
            // print("Con datos ${(completeQuestions.value as Map).length - 1}");
            // print("Con datos ${completeQuestions.value}");
            if ((completeQuestions.value as Map).length - 1 < objetivo) {
              //Si no ha llegado al objetivo
              objective =
                  "${(completeQuestions.value as Map).length - 1}/$objetivo";
              finalWidget = Text(
                objective,
                style: const TextStyle(fontSize: 16),
              );
            } else {
              //Si ha llegado al objetivo
              objective = "$objetivo/$objetivo"; //Se pone 6/6
              finalWidget = Row(
                children: [
                  Text(
                    objective,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 2),
                    child: Image.asset(
                      'assets/images/completada.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ],
              );
            }
          } else {
            print("No hay datos de preguntas completadas");
            objective = "0/$objetivo";
            finalWidget = Text(
              objective,
              style: const TextStyle(fontSize: 16),
            );
          }

        default:
          finalWidget = Container();
      }

      return finalWidget;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          //* Mi perfil */
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60,
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 128, 224, 119),
                border: Border.all(color: Colors.black)),
            child: const Center(
              child: Text(
                "Mi Perfil",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          GestureDetector(
            onTap: () {
              NavigatorState navigator = Navigator.of(context);
              navigator.push(MaterialPageRoute(builder: (context) {
                return Avatar(
                  avatarSelected: currentSelected!,
                );
              }));
            },
            child: FutureBuilder(
                future: getAvatar(userProvider.userKey),
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    currentSelected = snapshot.data['Indice'];
                    return Column(
                      children: [
                        Image.network(
                          snapshot.data['Enlace'],
                          width: 130,
                          height: 130,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Pulsa para cambiar",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    );
                  } else {
                    currentSelected = -1;
                    return Column(
                      children: [
                        Image.asset(
                          "assets/images/usuario.png",
                          width: 130,
                          height: 130,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Pulsa la imagen para seleccionar un avatar",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    );
                  }
                }),
          ),

          const SizedBox(
            height: 20,
          ),

          //* Logros */

          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 128, 224, 119),
                border: Border.all(color: Colors.black)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 35,
                ),
                const Text(
                  "Logros",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  width: 10,
                ),
                Image.asset('assets/images/logros.png', width: 35, height: 35)
              ],
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          FirebaseAnimatedList(
              shrinkWrap: true,
              query:
                  _userAchivements, //Pasar una query con los logros del dia filtrados
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                Map lista = {};
                lista['Texto'] = snapshot.value;
                lista['Key'] = snapshot.key;

                return ListTile(
                  title: Text("${lista['Texto']['Logro']}. ",
                      style: const TextStyle(fontSize: 16)),
                  leading: const Icon(
                    Icons.circle,
                    size: 12,
                  ),
                  trailing: SizedBox(
                    width: 75,
                    child: FutureBuilder(
                        future: getAchivementObjective(
                            lista['Texto']['Id'].toString(),
                            lista['Texto']['Objetivo']),
                        builder: (context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasData) {
                            // return Text(snapshot.data,
                            //     style: const TextStyle(fontSize: 16));
                            return snapshot.data;
                          } else {
                            return CircularProgressIndicator();
                          }
                        }),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                );
              }),

          const SizedBox(
            height: 20,
          ),

          //* Racha

          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 128, 224, 119),
                border: Border.all(color: Colors.black)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 125,
                ),
                const Text(
                  "Racha",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  width: 10,
                ),
                Image.asset('assets/images/racha.png', width: 35, height: 35),
                const SizedBox(
                  width: 70,
                ),
                GestureDetector(
                  onTap: () {
                    showInfo(context, 1, globalPoints);
                  },
                  child: const Icon(
                    Icons.info_outline,
                    size: 40,
                  ),
                )
              ],
            ),
          ),

          FutureBuilder(
              future: getMaxRacha(userProvider.userKey),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: 15),
                            child: FutureBuilder(
                              future: getRacha(userProvider.userKey),
                              builder:
                                  (context, AsyncSnapshot<dynamic> snapshot) {
                                return Text(
                                  "Racha de ${racha.toString()}",
                                  style: const TextStyle(fontSize: 16),
                                );
                              },
                            )),
                        Transform.translate(
                            offset: Offset(2, 5),
                            child: Image.asset('assets/images/racha.png',
                                width: 25, height: 25)),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Text(
                        snapshot.data,
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              }),
        ],
      ),
    );
  }

  Widget progress(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 60,
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 119, 191, 224),
                  border: Border.all(color: Colors.black)),
              child: const Center(
                child: Text(
                  "Mi progreso de la semana",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: FutureBuilder(
              future: getPointsChart(userProvider.userKey),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                //print(snapshot.data[0]);
                if (snapshot.hasData) {
                  Map<double, double> puntos = {};
                  for (int i = 1; i < snapshot.data.length + 1; i++) {
                    //Empieza en 1 y +1 ya que la grafica empieza en 1
                    puntos.addAll({
                      i.toDouble(): snapshot.data[i - 1].toDouble()
                    }); //-1 por que la lista empiza en 0
                  }

                  Widget text = Container();
                  text = testTendencie(puntos);

                  return Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 20,
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            minX: 1,
                            minY: 0,
                            maxX: 5,
                            maxY: 1500, //maximos valores
                            gridData: const FlGridData(
                              verticalInterval: 1,
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                  spots: puntos.entries
                                      .map((entry) =>
                                          FlSpot(entry.key, entry.value))
                                      .toList(), //key es el dia, value los puntos
                                  isCurved: true,
                                  preventCurveOverShooting: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (p0, p1, p2, p3) =>
                                        FlDotCirclePainter(
                                      color: Color.fromARGB(255, 165, 102, 207),
                                      strokeWidth: 2,
                                      strokeColor: Colors.black,
                                    ),
                                  ),
                                  color: Color.fromARGB(255, 165, 102, 207),
                                  barWidth: 4),
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  interval: 1,
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    //String text = '';
                                    Widget text = Container();
                                    switch (value.toInt()) {
                                      case 1:
                                        text = const Padding(
                                          padding: EdgeInsets.only(left: 35.0),
                                          child: Text(
                                            "Lunes",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                        );
                                        break;
                                      case 2:
                                        text = const Text(
                                          "Martes",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        );
                                        break;
                                      case 3:
                                        text = const Text(
                                          "Miercoles",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        );
                                        break;
                                      case 4:
                                        text = const Text(
                                          "Jueves",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        );
                                        break;
                                      case 5:
                                        text = const Padding(
                                          padding: EdgeInsets.only(right: 40.0),
                                          child: Text(
                                            "Viernes",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                        );
                                        break;
                                    }
                                    return text;
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                reservedSize: 40,
                                interval: 300,
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() == 0) {
                                    return Text('');
                                  } else {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    );
                                  }
                                },
                              )),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                          ),
                        ),
                      ),

                      //Texto
                      const SizedBox(
                        height: 20,
                      ),
                      text,
                    ],
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),

          //Texto
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //SnackBarService snackBarService = SnackBarService();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //scaffoldMessengerKey: snackBarService.scaffoldKey, //no deja abrir el texfield
      home: Scaffold(
        appBar: const TopBarStudentHome(
          arrow: false,
          backIndex: 0,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
                size: 30,
              ),
              label: 'Inicio',
              backgroundColor: Color.fromARGB(255, 157, 151, 202),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.emoji_events_outlined,
                size: 30,
              ),
              label: 'Ranking',
              backgroundColor: Color.fromARGB(255, 157, 151, 202),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.account_circle_outlined,
                size: 30,
              ),
              label: 'Mi perfil',
              backgroundColor: Color.fromARGB(255, 157, 151, 202),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.stacked_line_chart_rounded,
                size: 30,
              ),
              label: 'Mi progreso',
              backgroundColor: Color.fromARGB(255, 157, 151, 202),
            ),
          ],
          selectedFontSize: 15,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          selectedItemColor: Color.fromARGB(255, 255, 249, 191),
          unselectedItemColor: Color.fromARGB(255, 0, 0, 0),
          unselectedIconTheme: IconThemeData(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          currentIndex: currentPageIndex,
          onTap: _onItemTapped,
        ),
        backgroundColor: const Color.fromARGB(255, 245, 239, 216),
        body: SizedBox.expand(
          child: PageView(
            reverse: false,
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentPageIndex = index;
              });
              //snackBarService.removeSnackBar();
            },
            children: _widgetOptions
                .map((widgetFunction) => widgetFunction())
                .toList(),
          ),
        ),
        // body: Center(
        //   child: _widgetOptions.elementAt(currentPageIndex),
        // ),
      ),
    );
  }

  listQuestions(
      {required Map tareas,
      bool complete = false,
      int puntos = 0,
      required String userKey}) {
    return InkWell(
      onTap: () async {
        final Query _answers = FirebaseDatabase(
                databaseURL:
                    "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
            .ref()
            .child("Usuarios2")
            .child("Preguntas")
            .child(tareas['key'])
            .child("Respuestas");

        DateTime now = DateTime.now();

        int hour = checkQuestion(DateTime.now().hour, int.parse(tareas['key']));

        if (hour != 0) {
          showInfoQuestion(context, hour);
        } else if (complete) {
          initializeParameters(
              tareas["Pregunta"],
              colorList.elementAt(tareas["Color"]),
              totalPoints,
              dailyPoints,
              globalPoints,
              _answers,
              tareas['Tipo'],
              tareas['key']);

          await getAnswers(userKey, questionKey, complete);

          if (mounted) {
            Navigator.push<Widget>(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => Questions()));
          }
        } else {
          initializeParameters(
              tareas["Pregunta"],
              colorList.elementAt(tareas["Color"]),
              totalPoints,
              dailyPoints,
              globalPoints,
              _answers,
              tareas['Tipo'],
              tareas['key']);

          await getAnswers(userKey, questionKey, complete);

          if (mounted) {
            Navigator.push<Widget>(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => Questions()));
          }
        }
      },
      child: Container(
        // margin: const EdgeInsets.all(10),
        // padding: const EdgeInsets.all(10),
        height: 150,
        decoration: BoxDecoration(
            color: colorList.elementAt(tareas["Color"]),
            //borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Text(
                    tareas["Pregunta"],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: checkQuestion(
                          DateTime.now().hour, int.parse(tareas['key'])) !=
                      0
                  ? Image.asset(
                      'assets/images/candado.png',
                      width: 40,
                      height: 40,
                    )
                  : checkQuestion(
                              DateTime.now().hour, int.parse(tareas['key'])) !=
                          0
                      ? Image.asset(
                          'assets/images/candado.png',
                          width: 40,
                          height: 40,
                        )
                      : complete
                          ? Image.asset(
                              'assets/images/completada.png',
                              width: 40,
                              height: 40,
                            )
                          : const Icon(
                              Icons.check_box_outline_blank_outlined,
                              size: 30,
                            ),
            )
          ],
        ),
      ),
    );
  }
}

launchURL(DateTime now) async {
  if (now.weekday == DateTime.friday) {
    final Uri url = Uri.parse('https://forms.gle/pxGpkjWbtJGmdUEp7');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  } else if (now.weekday != DateTime.friday) {
    final Uri url = Uri.parse('https://forms.gle/AasrbbxGXEytjZMZA');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}

showStateDialog(BuildContext context, DateTime nowDate) {
  Widget reminderButton = ElevatedButton(
    style: const ButtonStyle(
      backgroundColor:
          MaterialStatePropertyAll(Color.fromARGB(255, 180, 179, 176)),
    ),
    child: const Text(
      "RECORDAR\nMAS TARDE",
      style: TextStyle(color: Colors.black, fontSize: 16),
    ),
    onPressed: () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('Shown', false);
      var horas = prefs.getInt('Horas');
      prefs.setInt('Horas', horas! + 1);

      NotificationProvider notificationProvider = NotificationProvider();
      notificationProvider
          .setNewNotification(DateTime.now().add(Duration(hours: 1)));
      Navigator.pop(context);
    },
  );
  Widget continueButton = ElevatedButton(
    style: const ButtonStyle(
      backgroundColor:
          MaterialStatePropertyAll(Color.fromARGB(255, 140, 212, 142)),
    ),
    child: const Text(
      "IR",
      style: TextStyle(color: Colors.black, fontSize: 18),
    ),
    onPressed: () async {
      launchURL(nowDate);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('Shown', true);
      prefs.setInt('Horas', 18);

      var now = DateTime.now();

      if (now.weekday == DateTime.friday) {
        NotificationProvider notificationProvider = NotificationProvider();
        notificationProvider
            .setNewNotification(DateTime(2024, now.month, now.day + 3, 18, 00));
      } else {
        NotificationProvider notificationProvider = NotificationProvider();
        notificationProvider
            .setNewNotification(DateTime(2024, now.month, now.day + 1, 18, 00));
      }

      var token = Provider.of<UserProvider>(context,
          listen: false); //* DESCOMENTAR PARA MONITORIZACION DE ESTUDIANTE */
      await registerActivity(token.userKey, "Accede a la encuesta");

      Navigator.pop(context);
    },
  );
  AlertDialog alert = AlertDialog(
    backgroundColor: Color.fromARGB(255, 231, 231, 231),
    surfaceTintColor: Colors.transparent,
    title: const Text(
      "¿Como te encuentras hoy?",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20),
    ),
    content: nowDate.weekday == DateTime.friday
        ? const Text(
            "¡Recuerda completar el Resumen de la semana!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          )
        : const Text(
            "¡Recuerda completar el Diario de aprendizaje!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
    actions: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          reminderButton,
          const SizedBox(
            width: 20,
          ),
          continueButton,
        ],
      )
    ],
  );

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

sendNotification(String title, String description) async {
  final data = {
    'click_action': 'FLUTTER_NOTIFICATION_CLICK',
    'id': '1',
    'status': 'done',
    'message': title,
  };

  try {
    http.Response response =
        await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization':
                  'key=AAAAsuHgIoI:APA91bE0P3bhiQOKYQknPcOji0eOFuds26w5id5B0Z4-5Kf-r2gsCU9PjT-2n0cgWkrQOPBe_Gy3XAOnvjBZ3puZSAlCDgbgQYo9GL2GzvraCBcNggWVPoT8cfZy_TZIuehtuhhMh5nN',
            },
            body: jsonEncode(<String, dynamic>{
              'notification': <String, dynamic>{
                'title': title,
                'body': description,
              },
              'priority': 'high',
              'data': data,
              'to': '/topics/pruebaAlerta',
            }));

    if (response.statusCode == 200) {
      print("Notificacion enviada");
    } else {
      print("Error");
    }
  } catch (e) {}
}

showSendNotificationDialog(BuildContext context) {
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();

  Widget continueButton = ElevatedButton(
    style: const ButtonStyle(
      backgroundColor:
          MaterialStatePropertyAll(Color.fromARGB(255, 140, 212, 142)),
    ),
    child: const Text(
      "Enviar",
      style: TextStyle(color: Colors.black, fontSize: 18),
    ),
    onPressed: () async {
      if (title.text.isEmpty || description.text.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Campos vacíos"),
              content:
                  const Text("Por favor, completa el título o la descripción."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Volver"),
                ),
              ],
            );
          },
        );
      } else {
        sendNotification(title.text, description.text);
        Navigator.pop(context);
      }
    },
  );
  AlertDialog alert = AlertDialog(
    backgroundColor: Color.fromARGB(255, 231, 231, 231),
    surfaceTintColor: Colors.transparent,
    title: const Text(
      "Enviar notificación",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20),
    ),
    content: Container(
      height: 200,
      width: 180,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Titulo de la notificación',
              labelStyle: const TextStyle(color: Colors.black),
              hintText: 'Titulo',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              ),
            ),
            controller: title,
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: ' Descripción',
                labelStyle: const TextStyle(color: Colors.black),
                hintText: 'Descripción',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
              ),
              maxLines: 8,
              controller: description,
            ),
          )
        ],
      ),
    ),
    actions: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          continueButton,
        ],
      )
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showInfo(BuildContext context, int tipo, int globalPoints) {
  Widget continueButton = ElevatedButton(
    style: const ButtonStyle(
      backgroundColor:
          MaterialStatePropertyAll(Color.fromARGB(255, 157, 151, 202)),
    ),
    child: const Text(
      "Continuar",
      style: TextStyle(color: Colors.black, fontSize: 16),
    ),
    onPressed: () async {
      Navigator.of(context, rootNavigator: true).pop(); // Cerrar el AlertDialog
    },
  );

  Widget text = Container();

  switch (tipo) {
    case 1:
      text = const Text(
        "Entra todos los días a la aplicación y completa los desafíos para aumentar tu racha y conseguir más puntos",
        softWrap: true,
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.left,
      );
      break;

    case 2:
      text = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            globalPoints < 4000
                ? "Tines la medalla de bronce"
                : globalPoints >= 4000 && globalPoints < 8000
                    ? "Tienes la medalla de plata"
                    : "Tienes la medalla de oro",
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.left,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            globalPoints < 8000
                ? "Para obetener la siguiente medalla completa las preguntas diarias"
                : "Ya tienes la medalla de oro, pero todavía puedes ganar mas puntos",
            softWrap: true,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.left,
          ),
        ],
      );
      break;
    default:
  }

  AlertDialog alert = AlertDialog(
    contentPadding: const EdgeInsets.only(left: 25, right: 25, top: 20),
    backgroundColor: const Color.fromARGB(255, 231, 231, 231),
    surfaceTintColor: Colors.transparent,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        text,
        const SizedBox(
          height: 20,
        ),
        const Text(
          "¡Inténtalo, tú puedes!",
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(
          height: 20,
        ),
        Image.asset(
          'assets/images/animadora.png',
          width: 150,
          height: 150,
        ),
      ],
    ),
    actions: [
      const SizedBox(
        height: 20,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          continueButton,
        ],
      )
    ],
  );

  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showInfoQuestion(BuildContext context, int hour) {
  Widget continueButton = ElevatedButton(
    style: const ButtonStyle(
      backgroundColor:
          MaterialStatePropertyAll(Color.fromARGB(255, 157, 151, 202)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Image.asset(
            'assets/images/recordar.png',
            width: 30,
            height: 30,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 20),
          child: Text(
            "Recordar",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ],
    ),
    onPressed: () async {
      DateTime now = DateTime.now();
      DateTime noti = DateTime(now.year, now.month, now.day, hour);

      print("La hora es: $hour");

      NotificationService().scheduleNotification(
          id: hour,
          title: 'Recuerda',
          body: 'Ya puedes completar las preguntas y conseguir puntos',
          scheduledNoti: noti);

      Navigator.of(context, rootNavigator: true).pop(); // Cerrar el AlertDialog
    },
  );

  AlertDialog alert = AlertDialog(
    contentPadding: const EdgeInsets.only(left: 25, right: 25, top: 10),
    backgroundColor: const Color.fromARGB(255, 231, 231, 231),
    surfaceTintColor: Colors.transparent,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 20,
        ),
        Text(
          "Esta pregunta se desbloquea a las $hour:00",
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 45.0),
          child: Image.asset(
            'assets/images/pregunta.png',
            width: 150,
            height: 150,
          ),
        ),
      ],
    ),
    actions: [
      const SizedBox(
        height: 20,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          continueButton,
        ],
      )
    ],
  );

  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showCompleteAchivement(BuildContext context) {
  Widget continueButton = ElevatedButton(
    style: const ButtonStyle(
      backgroundColor:
          MaterialStatePropertyAll(Color.fromARGB(255, 157, 151, 202)),
    ),
    child: const Center(
      child: Text(
        "Continuar",
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
    ),
    onPressed: () async {
      Navigator.of(context, rootNavigator: true).pop(); // Cerrar el AlertDialog
    },
  );

  AlertDialog alert = AlertDialog(
    contentPadding: const EdgeInsets.only(left: 25, right: 25, top: 10),
    backgroundColor: const Color.fromARGB(255, 231, 231, 231),
    surfaceTintColor: Colors.transparent,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 20,
        ),
        const Text(
          "¡Felicidades!",
          style: TextStyle(fontSize: 18),
        ),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                  text: "Has conseguido 100",
                  style: TextStyle(color: Colors.black, fontSize: 18)),
              WidgetSpan(
                alignment: PlaceholderAlignment.bottom,
                child: Transform.translate(
                  offset: Offset(4, 2),
                  child: Image.asset(
                    'assets/images/estrella.png',
                    width: 30,
                    height: 30,
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Image.asset(
          'assets/images/celebracion.png',
          width: 150,
          height: 150,
        ),
      ],
    ),
    actions: [
      const SizedBox(
        height: 20,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          continueButton,
        ],
      )
    ],
  );

  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
