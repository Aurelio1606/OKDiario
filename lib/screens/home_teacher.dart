import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/screens/calendar.dart';
import 'package:proyecto/screens/provider.dart';
import 'package:proyecto/screens/task.dart';
import 'package:proyecto/services/operations.dart';
import 'package:proyecto/widgets/widget_top_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherView extends StatefulWidget {
  const TeacherView({super.key});

  @override
  State<TeacherView> createState() => _TeacherViewState();
}

class _TeacherViewState extends State<TeacherView> {
  Widget teacherView(BuildContext context, String? userKey) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: const TopBarHome(
            arrow: true,
          ),
          backgroundColor: const Color.fromARGB(255, 245, 239, 216),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(5),
                        alignment: Alignment.centerLeft,
                        minimumSize:
                            MaterialStateProperty.all(const Size(400, 80)),
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 108, 206, 141)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                        side: MaterialStateProperty.all(
                          const BorderSide(
                            width: 1.5,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        var token = Provider.of<UserProvider>(context,
                            listen:
                                false); //* DESCOMENTAR PARA MONITORIZACION DE ESTUDIANTE */
                        await registerActivity(
                            token.userKey, "Accede a Mis Clases");

                        NavigatorState navigator = Navigator.of(context);
                        navigator.push(MaterialPageRoute(builder: (context) {
                          return LoadDataFromFireStore(
                            userKey: userKey,
                          );
                        }));
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mis Clases',
                            style: TextStyle(color: Colors.black, fontSize: 25),
                          ),
                          Icon(
                            Icons.arrow_right,
                            color: Colors.black,
                            size: 35,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 8, right: 8),
                  //   child: ElevatedButton(
                  //     style: ButtonStyle(
                  //       elevation: MaterialStateProperty.all(5),
                  //       alignment: Alignment.centerLeft,
                  //       minimumSize:
                  //           MaterialStateProperty.all(const Size(400, 80)),
                  //       backgroundColor: MaterialStateProperty.all(
                  //           Color.fromARGB(255, 140, 194, 226)),
                  //       shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8.0),
                  //       )),
                  //       side: MaterialStateProperty.all(
                  //         const BorderSide(
                  //           width: 1.5,
                  //           color: Colors.black,
                  //         ),
                  //       ),
                  //     ),
                  //     onPressed: () async {
                  //       //NotificationService().showNotification(title: 'Ejemplo', body: 'Ejemplo');
                  //       //DateTime prueba = DateTime.now().add(Duration(seconds: 5));
                  //       //print(prueba);
                  //       //print(DateTime.now());

                  //       //NotificationService().scheduleNotification(id: 1, title: 'INGLES', body: 'FACULTAD DE BELLAS ARTES',scheduledNoti: prueba);
                  //       //NotificationService().periodicDailyNotification(id: 2, title: 'prueba', body: 'Notificacion periodica diaria, hora 7',scheduledNoti: prueba);

                  //       // await NotificationService()
                  //       //     .checkPendingNotificationRequests(context);
                  //       // await FirebaseMessaging.instance
                  //       //     .subscribeToTopic("prueba1");
                  //       // await FirebaseMessaging.instance
                  //       //     .subscribeToTopic("prueba2");
                  //       await FirebaseMessaging.instance
                  //            .subscribeToTopic("pruebaAlerta");
                  //            print("Susxrioto");
                  //     },
                  //     child: const Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         Text(
                  //           'Agenda',
                  //           style: TextStyle(color: Colors.black, fontSize: 25),
                  //         ),
                  //         Icon(
                  //           Icons.arrow_right,
                  //           color: Colors.black,
                  //           size: 35,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(
                  //   height: 50,
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 8, right: 8),
                  //   child: ElevatedButton(
                  //     style: ButtonStyle(
                  //       elevation: MaterialStateProperty.all(5),
                  //       alignment: Alignment.centerLeft,
                  //       minimumSize:
                  //           MaterialStateProperty.all(const Size(400, 80)),
                  //       backgroundColor: MaterialStateProperty.all(
                  //           Color.fromARGB(255, 174, 154, 217)),
                  //       shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8.0),
                  //       )),
                  //       side: MaterialStateProperty.all(
                  //         const BorderSide(
                  //           width: 1.5,
                  //           color: Colors.black,
                  //         ),
                  //       ),
                  //     ),
                  //     onPressed: () async {
                  //       // NavigatorState navigator = Navigator.of(context);
                  //       // navigator.push(MaterialPageRoute(builder: (context) {
                  //       //   return const Login();
                  //       // }));
                  //       // String? name = await getUser(userKey!);
                  //       // print(userKey!);
                  //       //await registerActivity(userKey!, "Inicio de sesionssss");
                  //       //await NotificationService().checkPendingNotificationRequests(context);

                  //       // SharedPreferences prefs =
                  //       //     await SharedPreferences.getInstance();
                  //       //     prefs.setBool('subscrito', false);

                  //       // prefs.setInt('Horas', 18);
                  //       // prefs.setInt('Minutos', 00);
                  //       // prefs.setBool('Shown', false);

                  //       //showStateDialog(context, DateTime.now());
                  //       sendNotification('RECORDATORIO');
                  //     },
                  //     child: const Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         Text(
                  //           'Mis Notas',
                  //           style: TextStyle(color: Colors.black, fontSize: 25),
                  //         ),
                  //         Icon(
                  //           Icons.arrow_right,
                  //           color: Colors.black,
                  //           size: 35,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(
                  //   height: 50,
                  // ),
                  const SizedBox(
                    height: 80,
                  ),
                  //eqwie
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(5),
                        alignment: Alignment.centerLeft,
                        minimumSize:
                            MaterialStateProperty.all(const Size(400, 80)),
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 225, 220, 130)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                        side: MaterialStateProperty.all(
                          const BorderSide(
                            width: 1.5,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        // NavigatorState navigator = Navigator.of(context);
                        // navigator.push(MaterialPageRoute(builder: (context) {
                        //   return const Login();
                        // }));

                        //await NotificationService().cancelAllNotifications();

                        var token = Provider.of<UserProvider>(context,
                            listen:
                                false); //* DESCOMENTAR PARA MONITORIZACION DE ESTUDIANTE */
                        await registerActivity(
                            token.userKey, "Accede a Mis Tareas");
                        //await NotificationService().checkPendingNotificationRequests(context);
                        NavigatorState navigator = Navigator.of(context);
                        navigator.push(MaterialPageRoute(builder: (context) {
                          return LoadTasksData(
                            userKey: userKey,
                          );
                        }));
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mis Tareas',
                            style: TextStyle(color: Colors.black, fontSize: 25),
                          ),
                          Icon(
                            Icons.arrow_right,
                            color: Colors.black,
                            size: 35,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),

                  // if (true)
                  //   Padding(
                  //     padding: const EdgeInsets.only(left: 8, right: 8),
                  //     child: ElevatedButton(
                  //       style: ButtonStyle(
                  //         elevation: MaterialStateProperty.all(5),
                  //         alignment: Alignment.centerLeft,
                  //         minimumSize:
                  //             MaterialStateProperty.all(const Size(400, 80)),
                  //         backgroundColor: MaterialStateProperty.all(
                  //             Color.fromARGB(255, 225, 220, 130)),
                  //         shape:
                  //             MaterialStateProperty.all(RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(8.0),
                  //         )),
                  //         side: MaterialStateProperty.all(
                  //           const BorderSide(
                  //             width: 1.5,
                  //             color: Colors.black,
                  //           ),
                  //         ),
                  //       ),
                  //       onPressed: () async {
                  //         //showSendNotificationDialog(context);
                  //         // SharedPreferences prefs =
                  //         //     await SharedPreferences.getInstance();

                  //         //  prefs.setInt('RachaDia', 26);
                  //         // SharedPreferences prefs =
                  //         //     await SharedPreferences.getInstance();
                  //         // prefs.setInt('RachaDia', 8);
                  //       },
                  //       child: const Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Text(
                  //             'Mandar Notificacion',
                  //             style:
                  //                 TextStyle(color: Colors.black, fontSize: 25),
                  //           ),
                  //           Icon(
                  //             Icons.arrow_right,
                  //             color: Colors.black,
                  //             size: 35,
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return teacherView(context, userProvider.userKey);
  }
}
