import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/screens/provider.dart';
import 'package:proyecto/screens/task.dart';
import 'package:proyecto/services/notifications.dart';
import 'package:proyecto/services/snackBar.dart';

class TaskEditor extends StatefulWidget {
  const TaskEditor({super.key});

  @override
  TaskEditorState createState() => TaskEditorState();
}

class TaskEditorState extends State<TaskEditor> {
  ///Builds the editor interface for the tasks, where users can add the task name, its finalitation date
  ///and a description 
  Widget _getTaskEditor(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 245, 239, 216),
      child: ListView(
        children: <Widget>[
          ListTile(
            tileColor: const Color.fromARGB(255, 245, 239, 216),
            contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            leading: const Text(''),
            title: TextField(
              controller: TextEditingController(text: taskName),
              onChanged: (String value) {
                taskName = value;
              },
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: const TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Titulo Tarea',
              ),
            ),
          ),
          const Divider(
            height: 1.0,
            thickness: 1,
          ),
          ListTile(
            tileColor: const Color.fromARGB(255, 245, 239, 216),
            contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
            leading: const Text(''),
            title: TextField(
              controller: TextEditingController(text: description),
              onChanged: (String value) {
                description = value;
              },
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: const TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Descripcion Tarea',
              ),
            ),
          ),
          const Divider(
            height: 1.0,
            thickness: 1,
          ),
          ListTile(
              tileColor: const Color.fromARGB(255, 245, 239, 216),
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              leading: const Text(''),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: GestureDetector(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tarea Finaliza",
                            style: TextStyle(fontSize: 25),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            DateFormat('EEEE, d/M/y', 'es')
                                .format(endDate!)
                                .toUpperCase(),
                            textAlign: TextAlign.left,
                            style: const TextStyle(fontSize: 25),
                          ),
                        ],
                      ),
                      onTap: () async {
                        //Date picker for the tasks
                        final DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                          helpText: "SELECCIONAR FECHA",
                          builder: (context, child) {
                            return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color.fromARGB(255, 225, 220, 130),
                                    onPrimary: Colors.black,
                                    onSurface: Colors.black,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                        foregroundColor: const Color.fromARGB(
                                            255, 0, 0, 0), // button text color
                                        textStyle: const TextStyle(
                                          fontSize: 22, // button text size
                                        )),
                                  ),
                                ),
                                child: child!);
                          },
                        );

                        if (date != null) {
                          setState(() {
                            endDate = date;
                          });
                        }
                      },
                    ),
                  )
                ],
              )),
          const Divider(
            height: 1.0,
            thickness: 1,
          ),
        ],
      ),
    );
  }

  @override
  //builds the tasks interface where list of tasks is displayed
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final DatabaseReference _taskRef = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userProvider.userKey)
        .child("TaskData");

    SnackBarService snackBarService = SnackBarService();
    ///Generate an unique Id for each task
    int generateUniqueId() {
      DateTime now = DateTime.now();
      int random = Random().nextInt(100000) + 200000;
      int uniqueId = now.microsecond + random;

      return uniqueId;
    }

    return MaterialApp(
      scaffoldMessengerKey: snackBarService.scaffoldKey,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              "TAREA",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
            ),
          ),
          toolbarHeight: 100,
          backgroundColor: const Color.fromARGB(255, 157, 151, 202),
          leadingWidth: 75,
          leading: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 35,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Text(
                  "CERRAR",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  IconButton(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      icon: const Icon(
                        Icons.done,
                        color: Colors.black,
                        size: 35,
                      ),
                      onPressed: () async {
                        //if task name field or description filed are not empty
                        if (taskName.isNotEmpty || description.isNotEmpty) {
                          //if it is a new task
                          if (key.isEmpty) {
                            var newkey = _taskRef.push().key!;
                            var id = generateUniqueId();

                              //Adds the new task in the database
                            _taskRef.child(newkey).set({
                              "Key": newkey,
                              "Nombre": taskName,
                              "Descripcion": description,
                              "EndDate":
                                  DateFormat('yyyy-MM-dd').format(endDate!),
                              "TimeOut": timeOut,
                              "Eliminada": delete,
                              "Completada": complete,
                              "Id": id,
                            }).then((_) {
                              //shows a confirmation message
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('AÑADIDO CORRECTAMENTE')));
                            }).catchError((onError) {
                              print(onError);
                            });

                            var now = DateTime.now();

                            //Notifications for the tasks
                            if (endDate!.day != now.day) {
                              //if the task is due tomorrow a reminder is set at 4 pm
                              if (endDate!.day == now.day + 1) {                              
                                NotificationService().scheduleNotification(
                                    id: id,
                                    title: '¡Recuerda!',
                                    body: 'Tienes tarea: $taskName',
                                    scheduledNoti:
                                        endDate!.add(const Duration(hours: 16)));
                              } else {
                                //if the task is not due tomorrow the reminder is set one day 
                                //before it ends
                                NotificationService().scheduleNotification(
                                    id: id,
                                    title: '¡Recuerda!',
                                    body: 'Tienes tarea: $taskName',
                                    scheduledNoti: endDate!
                                        .add(const Duration(days: -1, hours: 16)));
                              }
                            } else {
                              //if the task is due today, there is no reminder
                              print('es hoy');
                            }

                            Navigator.pop(context);
                          } else {
                            //if the key was not empty it means the task already existed so the user updates it
                            //and the changes are saved in the database
                            _taskRef.child(key).set({
                              "Key": key,
                              "Nombre": taskName,
                              "Descripcion": description,
                              "EndDate":
                                  DateFormat('yyyy-MM-dd').format(endDate!),
                              "TimeOut": timeOut,
                              "Eliminada": delete,
                              "Completada": complete,
                              "Id": id,
                            }).then((_) {
                              //Confirmation message
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'TAREA ACTUALIZADA CORRECTAMENTE')));
                            }).catchError((onError) {
                              print(onError);
                            });

                            var now = DateTime.now();

                            //same logic as when creating a new task
                            if (endDate!.day != now.day) {
                              //if the task is due tomorrow a reminder is set at 4 pm
                              if (endDate!.day == now.day + 1) {
                                NotificationService().scheduleNotification(
                                    id: id,
                                    title: '¡Recuerda!',
                                    body: 'Tienes tarea: $taskName',
                                    scheduledNoti:
                                        endDate!.add(const Duration(hours: 16)));
                              } else {
                                //if the task is not due tomorrow the reminder is set one day 
                                //before it ends
                                NotificationService().scheduleNotification(
                                    id: id,
                                    title: '¡Recuerda!',
                                    body: 'Tienes tarea: $taskName',
                                    scheduledNoti: endDate!
                                        .add(const Duration(days: -1, hours: 16)));
                              }
                            } else {
                              //if the task is due today, there is no reminder
                              print('es hoy');
                            }

                            Navigator.pop(context);
                          }
                        } else {
                          //if the fields are empty it shows an alert
                          snackBarService.showSnackBar(
                              content: "PON NOMBRE O DESCRIPCION A LA TAREA");
                        }
                      }),
                  const Text(
                    "GUARDAR",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Stack(
            children: <Widget>[_getTaskEditor(context)],
          ),
        ),
      ),
    );
  }
}
