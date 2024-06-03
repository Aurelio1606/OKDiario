import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/screens/calendar.dart';
import 'package:proyecto/screens/provider.dart';
import 'package:proyecto/screens/task.dart';
import 'package:proyecto/services/operations.dart';
import 'package:proyecto/widgets/widget_top_home.dart';

class TeacherView extends StatefulWidget {
  const TeacherView({super.key});

  @override
  State<TeacherView> createState() => _TeacherViewState();
}

class _TeacherViewState extends State<TeacherView> {
  //builds admin/teacher view in the app
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
                            const Color.fromARGB(255, 108, 206, 141)),
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
                                false); 
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
                    height: 130,
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

                        var token = Provider.of<UserProvider>(context,
                            listen:
                                false); 
                        await registerActivity(
                            token.userKey, "Accede a Mis Tareas");
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
                  
                  //Button to send notifications to users 
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
                  //       sendNotification('RECORDATORIO');
                  //     },
                  //     child: const Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         Text(
                  //           'Mandar recordatorio',
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
