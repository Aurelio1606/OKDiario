import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto/screens/task_editor.dart';
import 'package:proyecto/services/notifications.dart';
import 'package:proyecto/widgets/widget_top_initial.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:proyecto/screens/provider.dart';
import 'package:provider/provider.dart';

class LoadTasks extends StatelessWidget {
  const LoadTasks({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FireBase',
      home: LoadTasksData(),
    );
  }
}

String taskName = '';
String description = '';
DateTime? endDate;
String key = '';
bool complete = false;
bool timeOut = false;
bool delete = false;
int id = 0;

class LoadTasksData extends StatefulWidget {
  final String? userKey;

  const LoadTasksData({Key? key, this.userKey}) : super(key: key);
  @override
  LoadTasksDataFromFireBase createState() => LoadTasksDataFromFireBase();
}

class LoadTasksDataFromFireBase extends State<LoadTasksData> {
  DataSnapshot? querySnapshot;
  dynamic data;

  String? dayText;

  @override
  void initState() {
    super.initState();
  }

  ///Checks if the first date [date1] is smaller than the second date [date2]
  compareDates(DateTime date1, DateTime date2) {
    if (date1.day < date2.day) {
      if (date1.month <= date2.month) {
        return true;
      }
    }

    return false;
  }

  @override
  //Builds tasks interface where user can add new tasks, complete or delete them
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final Query _userTasks = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userProvider.userKey)
        .child("TaskData")
        .orderByChild("EndDate");

    final DatabaseReference _completeTask = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userProvider.userKey)
        .child("TaskData");

    return Scaffold(
      appBar: const TopBarInitial(
        arrow: true,
      ),
      floatingActionButton: Container(
        height: 70,
        width: 70,
        child: FittedBox(
          //Button to add a new task
          child: FloatingActionButton(
            splashColor: Colors.black,
            backgroundColor: const Color.fromARGB(255, 231, 231, 231),
            child: const Column(
              children: [
                Icon(
                  Icons.add,
                  color: Color.fromARGB(255, 64, 158, 235),
                  size: 30,
                ),
                Text(
                  "AÑADIR",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            onPressed: () {
              //variables initialization for a new task
              taskName = '';
              description = '';
              key = '';
              endDate = DateTime.now();
              timeOut = false;
              complete = false;
              delete = false;
              id = 0;

              //Redirects user to task editor
              Navigator.push<Widget>(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const TaskEditor()),
              );
            },
          ),
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 245, 239, 216),
        height: double.infinity,
        child: FirebaseAnimatedList(
            query: _userTasks,
            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                Animation<double> animation, int index) {
              Map tareas = snapshot.value as Map;
              tareas['key'] = snapshot.key;

              //checks if a task deadline has passed to delete it from the tasks list 
              //and mark it as not completed in the database
              if (compareDates(
                  DateTime.tryParse(tareas["EndDate"])!, DateTime.now())) {
                timeOut = true;
                endDate = DateTime.now(); 

                _completeTask.child(tareas['key']).update({
                  "Key": tareas['key'],
                  "Nombre": taskName,
                  "Descripcion": description,
                  "EndDate": DateFormat('yyyy-MM-dd').format(endDate!),
                  "Completada": complete,
                  "TimeOut": timeOut,
                  "Eliminada": delete,
                  "Id": id,
                });

                return Container();
              } else if (tareas["Completada"] ||
                  tareas["Eliminada"] ||
                  tareas["TimeOut"]) {
                    //if the task is marked as completed, deleted or timeout it is not displayed
                    //in the tasks list
                return Container();
              } else {
                //tasks list
                return listItem(tareas: tareas);
              }
            }),
      ),
    );
  }

  Widget listItem({required Map tareas}) {
    return InkWell(
      onTap: () {
        //variable initialization if the task already existed
        taskName = tareas["Nombre"];
        description = tareas["Descripcion"];
        key = tareas["Key"];
        endDate = DateTime.tryParse(tareas["EndDate"]);
        timeOut = tareas["TimeOut"];
        complete = tareas["Completada"];
        delete = tareas["Eliminada"];
        id = tareas["Id"];
        
        //Redirects user to task editor
        Navigator.push<Widget>(
          context,
          MaterialPageRoute(builder: (BuildContext context) => const TaskEditor()),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        height: 230,
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 240, 209, 115),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //build tasks interface using the information retrieve from the database
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tareas["Nombre"],
                      style:
                          const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Divider(
                      height: 1.0,
                      thickness: 1,
                      color: Colors.black,
                    ),
                    Text(
                      tareas["Descripcion"],
                      style:
                          const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Divider(
                      height: 1.0,
                      thickness: 1,
                      color: Colors.black,
                    ),
                    const Text(
                      "Tarea Finaliza",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      DateFormat('EEEE, d/M/y', 'es')
                          .format(DateTime.parse(tareas["EndDate"])),
                      style:
                          const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    // No hay Expanded aquí, para evitar que el contenido crezca infinitamente
                  ],
                ),
              ),
            ),
            const VerticalDivider(
              width: 1,
              thickness: 1,
              color: Colors.black,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Button to mark the task as completed
                    IconButton(
                      onPressed: () {
                        showCompleteDialog(context, tareas["Key"], tareas["Id"]);
                      },
                      icon: const Icon(
                        Icons.done_outline,
                        size: 30,
                      ),
                    ),
                    const Text(
                      "COMPLETADA",
                      style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0), fontSize: 13),
                    ),
                    //Button to delete the task
                    IconButton(
                      onPressed: () {
                        showAlertDialog(context, tareas["Key"], tareas["Id"]);
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 30,
                      ),
                    ),
                    const Text(
                      "BORRAR",
                      style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0), fontSize: 13),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///Shows an alert dialog to confirm if the user want to delete the task
showAlertDialog(BuildContext context, String key, int cancelId) {
  Widget cancelButton = ElevatedButton(
    style: const ButtonStyle(
      backgroundColor:
          MaterialStatePropertyAll(Color.fromARGB(255, 180, 179, 176)),
    ),
    child: const Text(
      "NO",
      style: TextStyle(color: Colors.black, fontSize: 18),
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = ElevatedButton(
    style: const ButtonStyle(
      backgroundColor:
          MaterialStatePropertyAll(Color.fromARGB(255, 140, 212, 142)),
    ),
    child: const Text(
      "SI",
      style: TextStyle(color: Colors.black, fontSize: 18),
    ),
    onPressed: () {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final DatabaseReference _deleteTask = FirebaseDatabase(
              databaseURL:
                  "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
          .ref()
          .child("Usuarios2")
          .child("DatosUsuario")
          .child(userProvider.userKey)
          .child("TaskData");

      timeOut = false;
      complete = false;
      delete = true;
      //if the user delete the task it is saved in the database as 'eliminada' to
      //know that the user deleted it
      _deleteTask.child(key).set({
        "Key": key,
        "Nombre": taskName,
        "Descripcion": description,
        "EndDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "Completada": complete,
        "TimeOut": timeOut,
        "Eliminada": delete,
        "Id": cancelId,
      });

      //deletes reminder associated to the task
      NotificationService().cancelSpecificNotifications(cancelId);

      Navigator.pop(context);
    },
  );
  AlertDialog alert = AlertDialog(
    backgroundColor: const Color.fromARGB(255, 231, 231, 231),
    surfaceTintColor: Colors.transparent,
    content: const Text(
      "¿Quieres eliminar esta tarea?",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20),
    ),
    actions: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          cancelButton,
          const SizedBox(
            width: 15,
          ),
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

///Shows an alert dialog to confirm if the user want to complete the task
showCompleteDialog(BuildContext context, String key, int cancelId) {
  Widget cancelButton = ElevatedButton(
    style: const ButtonStyle(
      backgroundColor:
          MaterialStatePropertyAll(Color.fromARGB(255, 180, 179, 176)),
    ),
    child: const Text(
      "NO",
      style: TextStyle(color: Colors.black, fontSize: 18),
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = ElevatedButton(
    style: const ButtonStyle(
      backgroundColor:
          MaterialStatePropertyAll(Color.fromARGB(255, 140, 212, 142)),
    ),
    child: const Text(
      "SI",
      style: TextStyle(color: Colors.black, fontSize: 18),
    ),
    onPressed: () {
      showFinalDialog(context, key, cancelId);
    },
  );
  AlertDialog alert = AlertDialog(
    backgroundColor: const Color.fromARGB(255, 231, 231, 231),
    surfaceTintColor: Colors.transparent,
    content: const Text(
      "¿Has completado la tarea?",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20),
    ),
    actions: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          cancelButton,
          const SizedBox(
            width: 15,
          ),
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

///Shows an alert dialog when the user confim the completation of a task ans shows positive feedback
showFinalDialog(BuildContext context, String key, int cancelId) {
  Widget continueButton = ElevatedButton(
    style: const ButtonStyle(
      backgroundColor:
          MaterialStatePropertyAll(Color.fromARGB(255, 140, 212, 142)),
    ),
    child: const Text(
      "CERRAR",
      style: TextStyle(color: Colors.black, fontSize: 18),
    ),
    onPressed: () {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final DatabaseReference _deleteTask = FirebaseDatabase(
              databaseURL:
                  "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
          .ref()
          .child("Usuarios2")
          .child("DatosUsuario")
          .child(userProvider.userKey)
          .child("TaskData");

      timeOut = false;
      complete = true;
      delete = false;

      //Saves the task as 'completada' in the database
      _deleteTask.child(key).set({
        "Key": key,
        "Nombre": taskName,
        "Descripcion": description,
        "EndDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "Completada": complete,
        "TimeOut": timeOut,
        "Eliminada": delete,
        "Id": cancelId,
      });

      //deletes reminder associated to the task
      NotificationService().cancelSpecificNotifications(cancelId);

      Navigator.pop(context);
      Navigator.pop(context);
    },
  );
  AlertDialog alert = AlertDialog(
    backgroundColor: Color.fromARGB(255, 231, 231, 231),
    surfaceTintColor: Colors.transparent,
    content: const Text(
      "¡Enhorabuena por completar la tarea!",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20),
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
