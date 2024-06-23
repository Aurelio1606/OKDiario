import 'package:circle_list/circle_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/screens/home_estudent.dart';
import 'package:proyecto/screens/provider.dart';
import 'package:proyecto/services/snackBar.dart';
import 'package:proyecto/widgets/widget_top_homeStudent.dart';

class Questions extends StatefulWidget {
  const Questions({super.key});

  @override
  State<Questions> createState() => _Questions();
}

class _Questions extends State<Questions> {
  int cont = 0;

  ///saves user's write answer
  final TextEditingController answer = TextEditingController();

  ///List with answer to multiple choice questions
  List<String?> isChecked = [];

  ///List of emojis selected
  List<bool?> imageIsMarked = [];

  ///choosen answer's index
  int? currentIndex;

  ///controller for page view
  PageController? _pageController;

  ///List of indexes of the selected emojis
  List<int?> selectedImages = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (writenField != 'null') {
      answer.text = writenField;
    }

    currentIndex = testField;
  }

  @override
  void dispose() {
    super.dispose();
    answer.dispose();
    indexField.clear();
  }

  ///Returns the number of answers to a question
  getNumAnswers(Query answers) async {
    DataSnapshot snapshot = await answers.get();

    //tam -1 so that the writing field and the button are added to the end of the list
    //regardless of the number od responses
    return (snapshot.value as Map).length - 1;
  }

  ///Returns current week number
  int getWeekNumber() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, 1, 1);

    DateTime from = DateTime.utc(firstDay.year, firstDay.month, firstDay.day);
    DateTime to = DateTime.utc(now.year, now.month, now.day);
    return ((to.difference(from).inDays + firstDay.weekday) / 7).ceil();
  }

  ///Returns a list with the images's names the user has choosen
  getImageName(List<bool?> images) {
    List<String> names = [
      'Calmado',
      'Confundido',
      'Enfadado',
      'Preocupado',
      'Triste',
      'Aburrido',
      'Alegre',
      'Emocionado',
    ];

    List<String> selectedNames = [];

    //If an image is choosen by the user (is true in selectedNames) the name for that image
    //is stored in selectedImages according to the index for the list declared aboved
    if (images.isNotEmpty) {
      for (int i = 0; i < images.length; i++) {
        if (images[i] == true) {
          selectedNames.add(names.elementAt(i));
          selectedImages.add(i);
        }
      }
    }

    return selectedNames;
  }

  ///Updates totalPoints in the database
  updateTotalPoints(String userKey, int updatePoints) async {
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

  ///Updates dailyPoints in the database
  updatePoints(String userKey, int updatePoints) async {
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

  ///Updates globalPoints in the database
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

  ///Saves the answer [argument], the write fiel [text] and the question index [index]
  ///using the user key [userKey] nad the question key [questionKey] in the database
  saveAnswer(String userKey, dynamic argument, String questionKey, String text,
      dynamic index) {
    final DatabaseReference _saveAnswer = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey)
        .child("InfoRespuestas")
        .child(DateTime.now().month.toString());

    var dia = DateTime.now().weekday.toString();

    answer.text.isEmpty
        ? _saveAnswer
            .child(getWeekNumber().toString())
            .child(dia)
            .child(questionKey)
            .update({
            "Respuesta": argument,
            "RespuestaEscrita": "null",
            "Indice": index,
          })
        : _saveAnswer
            .child(getWeekNumber().toString())
            .child(dia)
            .child(questionKey)
            .update({
            "Respuesta": argument,
            "RespuestaEscrita": answer.text,
            "Indice": index,
          });
  }

  ///Builds the interface for the answers to the questions, returning a list of the answers
  ///and allowing the user to pick one or multiple answers.
  listQuestions(
      {required Map tareas, required int index, String questionKey = ""}) {
    Map<int, String> imageMap = {
      0: 'assets/images/emotions/emocionado.png',
      1: 'assets/images/emotions/alegre.png',
      2: 'assets/images/emotions/preocupado.png',
      3: 'assets/images/emotions/enfado.png',
      4: 'assets/images/emotions/triste.png',
    };
    return InkWell(
      onTap: () {
        setState(() {
          if (currentIndex != index) {
            currentIndex = index;
          } else {
            currentIndex = null;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        height: 80,
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 247, 236, 194),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 1.5)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            questionKey == '10'
                ? Image.asset(
                    imageMap[index]!,
                    width: 70,
                    height: 70,
                  )
                : Container(),
            Expanded(
              child: Text(
                tareas["respuesta"],
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Transform.scale(
                scale: 1.5,
                child: Checkbox(
                  side: MaterialStateBorderSide.resolveWith(
                      (states) => const BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          )),
                  checkColor: const Color.fromARGB(255, 0, 0, 0),
                  activeColor: const Color.fromARGB(255, 101, 196, 104),
                  shape: const CircleBorder(side: BorderSide(width: 1)),
                  value: currentIndex == index,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        currentIndex = index;
                      } else {
                        currentIndex = null;
                      }
                    });
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  ///Builds a writing field's interface for each question, where user can enter
  ///alternative answer
  Widget writeField() {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      height: 80,
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 245, 239, 216),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black)),
      child: Row(
        children: [
          const Text(
            "Otra: ",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: TextField(
              controller: answer,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromARGB(255, 190, 190, 190),
                hintText: 'Escribe tu respuesta',
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
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  ///builds the complete interface button, updates the points and saves the answer in the database
  Widget completeButton(dynamic argument, dynamic correctArgument,
      String userKey, String questionKey, SnackBarService snackBarService) {
    return ElevatedButton(
      onPressed: () {
        if (argument == correctArgument) {
          //If is the emotiosn question
          if (argument is List) {
            //If the list has no true strored and the text is empty
            if (!(argument as List).any((element) => element == true) &&
                answer.text.isEmpty) {
              snackBarService.showSnackBar(content: "COMPLETA LA PREGUNTA");
            } else {
              argument = getImageName(correctArgument);

              if (!questionComplete) {
                updateTotalPoints(userKey, totalPuntuation + 100);
                updatePoints(userKey, dayPoints + 100);
                updateGlobalPoints(userKey, globalPuntuation + 100);
                saveAnswer(userKey, argument, questionKey, answer.text,
                    selectedImages);
                showRightDialog(context, _pageController!);
              } else {
                saveAnswer(userKey, argument, questionKey, answer.text,
                    selectedImages);
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) {
                  return const StudentView();
                }));
              }
            }
          } else {
            if (argument.isEmpty && answer.text.isEmpty) {
              snackBarService.showSnackBar(content: "COMPLETA LA PREGUNTA");
            } else {
              if (!questionComplete) {
                updateTotalPoints(userKey, totalPuntuation + 100);
                updatePoints(userKey, dayPoints + 100);
                updateGlobalPoints(userKey, globalPuntuation + 100);
                saveAnswer(userKey, argument, questionKey, answer.text,
                    currentIndex);
                showRightDialog(context, _pageController!);
              } else {
                saveAnswer(userKey, argument, questionKey, answer.text,
                    currentIndex);
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) {
                  return const StudentView();
                }));
              }
            }
          }
        } else {
          //for the multiple choice questions,
          //if user has a wrong choice and the text field is empty, an alert is shown
          if (answer.text.isEmpty && argument.isNotEmpty) {
            showWrongDialog(context);
          } else if (answer.text.isEmpty) {
            snackBarService.showSnackBar(content: "COMPLETA LA PREGUNTA");
          } else {
            //If user has not picked a choice but has written an answer
            if (!questionComplete) {
              updateTotalPoints(userKey, totalPuntuation + 100);
              updatePoints(userKey, dayPoints + 100);
              updateGlobalPoints(userKey, globalPuntuation + 100);
              saveAnswer(
                  userKey, argument, questionKey, answer.text, currentIndex);
              showRightDialog(context, _pageController!);
            } else {
              saveAnswer(
                  userKey, argument, questionKey, answer.text, currentIndex);
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) {
                return const StudentView();
              }));
            }
          }
        }
      },
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(5),
        // alignment: Alignment.centerLeft,
        minimumSize: MaterialStateProperty.all(const Size(250, 60)),
        backgroundColor:
            MaterialStateProperty.all(const Color.fromARGB(255, 157, 151, 202)),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        )),
        side: MaterialStateProperty.all(
          const BorderSide(
            width: 1.5,
            color: Colors.black,
          ),
        ),
      ),
      child: const Text(
        "¡Completado!",
        style: TextStyle(color: Colors.black, fontSize: 20),
      ),
    );
  }

  ///Builds the interface for the multiple choices questions
  Widget testQuestion(String userKey, String questionType, String questionKey,
      SnackBarService snackBarService) {
    Map<int, String> placeMap = {
      1: 'Aulario de Derecho',
      2: 'Aulario de Derecho',
      3: 'ETSIIT Informática',
      4: 'Ciencias de la Educación',
      5: 'Mañana no hay clase',
      6: 'Mañana no hay clase',
      7: 'Mañana no hay clase',
    };

    String place = "";
    String correctPlace = "default";

    //futureBuilder to get the response number
    //then it build the list
    return Container(
      child: Flexible(
        child: FutureBuilder(
            future: getNumAnswers(answers!),
            builder: (context, AsyncSnapshot<dynamic> numSnapshot) {
              if (numSnapshot.hasData) {
                return FirebaseAnimatedList(
                    shrinkWrap: true,
                    query: answers!,
                    itemBuilder: (BuildContext context, DataSnapshot snapshot,
                        Animation<double> animation, int index) {
                      Map tareas = {};
                      tareas['respuesta'] = snapshot.value;
                      tareas['key'] = snapshot.key;
                      cont++;

                      isChecked.add(tareas[
                          'respuesta']); //List with the answers to multiple choice questions

                      //If any are selected
                      if (currentIndex != null) {
                        //if the list is smaller than the selected one (all responses have not been loaded yet)
                        if (currentIndex! < isChecked.length) {
                          place = isChecked[
                              currentIndex!]!; //waits, if the list is longer, the selected answer is marked
                        }
                        
                        //if so that it is only checked from monday to thursday
                        if (DateTime.now().weekday < 5) {
                          questionKey == '1'
                              ? correctPlace = placeMap[DateTime.now().weekday]!
                              : correctPlace = placeMap[DateTime.now()
                                  .add(const Duration(days: 1))
                                  .weekday]!;
                        } else {
                          correctPlace = placeMap[DateTime.now()
                              .add(const Duration(days: 1))
                              .weekday]!;
                        }
                      }

                      if (index < numSnapshot.data) {
                        return listQuestions(
                            tareas: tareas,
                            index: index,
                            questionKey: questionKey);
                      } else {
                        return Column(
                          children: [
                            listQuestions(
                                tareas: tareas,
                                index: index,
                                questionKey: questionKey),
                            writeField(),
                            const SizedBox(
                              height: 20,
                            ),
                            questionKey != '1' && questionKey != '30'
                                ? completeButton(place, place, userKey,
                                    questionKey, snackBarService)
                                : completeButton(place, correctPlace, userKey,
                                    questionKey, snackBarService),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        );
                      }
                    });
              } else {
                return CircularProgressIndicator();
              }
            }),
      ),
    );
  }

  ///Builds the interface for the emotions question
  Widget circleQuestion(String userKey, String questionType, String questionKey,
      SnackBarService snackBarService) {
    int contador = 0;
    ///Map with images routes and name of the images of emotions
    Map<String, String> imagesMap = {
      'assets/images/emotions/calmado.png': 'Calmado',
      'assets/images/emotions/confundido.png': 'Confundido',
      'assets/images/emotions/enfado.png': 'Enfadado',
      'assets/images/emotions/preocupado.png': 'Preocupado',
      'assets/images/emotions/triste.png': 'Triste',
      'assets/images/emotions/aburrido.png': 'Aburrido',
      'assets/images/emotions/alegre.png': 'Alegre',
      'assets/images/emotions/emocionado.png': 'Emocionado',
    };

    //Stores 'true' in the corresponding position if the user has picked an image 
    while (imageIsMarked.length <= imagesMap.length) {
      bool marked = indexField.contains(contador);

      imageIsMarked.add(marked);

      contador++;
    }

    return Container(
      child: Expanded(
        child: ListView(
          children: [
            CircleList(
              outerRadius:
                  183, //adjust the size of the circle, so that it does not overlap below
              initialAngle: 0,
              dragAngleRange: DragAngleRange(0, 0),
              origin: const Offset(0, 0),
              centerWidget: const Text(
                "Selecciona como te encuentras hoy",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              children: imagesMap.keys.map((images) {
                int index = imagesMap.keys.toList().indexOf(images);

                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        //Select or deselect an image
                        imageIsMarked[index] = !imageIsMarked[index]!;
                      });
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        //if the user tap on an image, the image is undelined yellow so the user knows
                        //they have selected that image
                        color: imageIsMarked[index]!
                            ? const Color.fromARGB(255, 250, 228, 130)
                            : Colors.transparent,
                      ),
                      child: Transform.translate(
                        offset: const Offset(0, 4),
                        child: Column(
                          children: [
                            Image.asset(
                              images,
                              width: 60,
                              height: 60,
                            ),
                            Text(
                              imagesMap[images]!,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 15),
              child: writeField(),
            ),
            Align(
              child: Container(
                padding: const EdgeInsets.only(bottom: 15),
                width: 250,
                child: completeButton(imageIsMarked, imageIsMarked, userKey,
                    questionKey, snackBarService),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///Builds interface for questions that only have a write field
  Widget writeQuestion(String userKey, String questionType, String questionKey,
      SnackBarService snackBarService) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 20,
              ),
              TextField(
                maxLines: 5,
                //controller that stores the user's answer in respuesta
                controller: answer,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 190, 190, 190),
                  hintText: 'Escribe tu respuesta',
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
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
              const SizedBox(
                height: 20,
              ),
              completeButton(answer.text, answer.text, userKey,
                  questionKey, snackBarService),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SnackBarService snackBarService = SnackBarService();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return MaterialApp(
      scaffoldMessengerKey: snackBarService.scaffoldKey,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: const TopBarStudentHome(
          arrow: true,
          backIndex: 0,
        ),
        body: Container(
          color: const Color.fromARGB(255, 245, 239, 216),
          child: Column(children: [
            Container(
              decoration: BoxDecoration(
                  color: color,
                  border: Border.all(width: 1, color: Colors.black)),
              height: 100,
              width: double.infinity,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Text(
                    question,
                    style: const TextStyle(fontSize: 25),
                  ),
                ),
              ),
            ),

            //Type of questions
            //0 -> emotions circle question
            //1 -> multiple choice question
            //2 -> write field question
            if (questionType == '0')
              circleQuestion(userProvider.userKey, questionType, questionKey,
                  snackBarService),
            if (questionType == '1')
              testQuestion(userProvider.userKey, questionType, questionKey,
                  snackBarService),
            if (questionType == '2')
              writeQuestion(userProvider.userKey, questionType, questionKey,
                  snackBarService),
          ]),
        ),
      ),
    );
  }

  ///shows an alert dialog when the user answers a question correctly.
  showRightDialog(BuildContext context, PageController pageController) {
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
        answer.clear();
        Navigator.of(context, rootNavigator: true)
            .pop(); //close the AlertDialog

        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 1000),
            pageBuilder: (_, __, ___) => StudentView(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return child;
            },

            // transitionsBuilder: (context, animation, secondaryAnimation, child) {
            //   const begin = Offset(1, 0);
            //   const end = Offset.zero;
            //   final tween = Tween(begin: begin, end: end);
            //   final offsetAnimation = animation.drive(tween);
            //   return SlideTransition(
            //     position: offsetAnimation,
            //     child: child,
            //   );
            // },
          ), // Página principal
          (Route<dynamic> route) =>
              false, //Remove all remaining routes from the stack
        );
      },
    );

    AlertDialog alert = AlertDialog(
      contentPadding: const EdgeInsets.all(5),
      insetPadding: const EdgeInsets.all(10),
      backgroundColor: const Color.fromARGB(255, 231, 231, 231),
      surfaceTintColor: Colors.transparent,
      title: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          children: [
            //Positive feedback
            Image.asset(
              "assets/images/confeti.png",
              width: 60,
              height: 60,
            ),
            const Text(
              "¡Felicidades!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25),
            ),
            Image.asset(
              "assets/images/confeti.png",
              width: 60,
              height: 60,
            ),
          ],
        ),
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //the points that the user has earned
          const Text(
            "Has conseguido 100",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 21),
          ),
          const SizedBox(
            width: 10,
          ),
          Transform.translate(
            offset: const Offset(0, -3),
            child: Image.asset(
              "assets/images/estrella.png",
              width: 30,
              height: 30,
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
}

///shows an alert dialog when the user answer a question wrong
showWrongDialog(BuildContext context) {
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
      Navigator.of(context, rootNavigator: true).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    contentPadding: const EdgeInsets.all(5),
    backgroundColor: const Color.fromARGB(255, 231, 231, 231),
    surfaceTintColor: Colors.transparent,
    title: const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        "Has fallado",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 25),
      ),
    ),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //positive feedback
        const Text(
          "¡No te preocupes,\n sigue intentándolo",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 21),
        ),
        const SizedBox(
          width: 10,
        ),
        Image.asset(
          "assets/images/carasonriente.png",
          width: 60,
          height: 60,
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
          const SizedBox(
            height: 10,
          ),
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
