import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:proyecto/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:proyecto/models/students_model.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:proyecto/screens/provider.dart';

final DatabaseReference _contadorRef = FirebaseDatabase(
        databaseURL:
            "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
    .ref()
    .child("contadorUsuarios");
final DatabaseReference _userRef = FirebaseDatabase(
        databaseURL:
            "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
    .ref()
    .child("alumnos");

final DatabaseReference _userRegistered = FirebaseDatabase(
        databaseURL:
            "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
    .ref()
    .child("Usuarios2")
    .child("DatosUsuario");

final DatabaseReference _userActivity = FirebaseDatabase(
        databaseURL:
            "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
    .ref()
    .child("Usuarios2")
    .child("Actividad");

// Future<void> guardarUsuarios(Student user) async {
//   DatabaseEvent numUsersEvent = await _contadorRef.once();

//   if (numUsersEvent.snapshot != null) {
//     DataSnapshot numUsers = numUsersEvent.snapshot;

//     int cont = int.tryParse(numUsers.value.toString()) ?? 0;

//     _userRef.child(cont.toString()).set(user.toJson());
//     _contadorRef.set(cont + 1);
//   } else {
//     print("Error");
//   }
// }

Future<List<Student>> getUsuarios() async {
  List<Student> estudiantes = [];

  try {
    // Obtener el DatabaseEvent usando onValue
    DatabaseEvent event = await _userRef.onValue.first;

    // Obtener el DataSnapshot desde el evento
    DataSnapshot dataSnapshot = event.snapshot;

    final data = dataSnapshot.value;

    // Verificar si hay datos y si es una lista
    if (data != null && data is List) {
      // Realizar un casting a List<dynamic>
      final lista = data;

      // Iterar sobre los elementos de la lista
      for (var item in lista) {
        var estudiante = Student.fromJson(item);
        estudiantes.add(estudiante);
      }
    } else {
      print('Datos no válidos');
    }
  } catch (e) {
    print("Error: $e");
  }

  return estudiantes;
}

Future<void> userRegister(
    String name, String second, String password, String email) async {
  String key = _userRegistered.push().key!;
  //final fcmToken = await FirebaseMessaging.instance.getToken();

  try {
    await _userRegistered.child(key).set({
      "Nombre": name,
      "Apellidos": second,
      "Contraseña": password,
      "Correo": email,
      "Key": key,
    });
  } catch (e) {
    print(e);
  }
}

Future<String?> validateData(String name, String password) async {
  String? key = '';

  try {
    DataSnapshot usuarios = await _userRegistered.get();

    if (usuarios.exists) {
      for (var user in usuarios.children) {
        if ((user.value as Map)["Nombre"] == name &&
            (user.value as Map)["Contraseña"] == password) {
          print("Correcto");
          key = user.key;

          return key;
        } else {
          print("Incorrecto");
        }
      }
      return key;
    }

    return key;
  } catch (e) {
    print(e);
    return key;
  }
}

Future<String?> getUser(String key) async {
  String name = '';

  try {
    DataSnapshot usuario = await _userRegistered.child(key).get();

    if (usuario.exists) {
      name = (usuario.value as Map)["Nombre"];
      print("El usuario es $name");
    } else {
      print("El usuario no existe");
    }
  } catch (e) {
    print("Error: $e");
  }

  return name;
}

Future<void> registerActivity(String userkey, String activity) async {
  String? user = await getUser(userkey);

  //String key = _userRegistered.push().key!;
  String day = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
  String hour = DateFormat('HH:mm:ss').format(DateTime.now()).toString();
  try {
    await _userActivity.child(user!).child(day).child(hour).set({
      "Nombre": user,
      "Actividad": activity,
    });
  } catch (e) {
    print(e);
  }
}

Future<List<Task>> getTareas(String userkey) async {
  final DatabaseReference _userTasks = FirebaseDatabase(
          databaseURL:
              "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
      .ref()
      .child("Usuarios2")
      .child("DatosUsuario")
      .child(userkey)
      .child("TaskData");

  List<Task> tareas = [];

  try {
    // Obtener el DatabaseEvent usando onValue
    DatabaseEvent event = await _userTasks.onValue.first;

    // Obtener el DataSnapshot desde el evento
    DataSnapshot dataSnapshot = event.snapshot;

    final data = dataSnapshot.value;

    // Verificar si hay datos y si es una lista
    if (data != null && data is List) {
      // Iterar sobre los elementos de la lista
      for (var item in data) {
        // Verificar si el elemento es un mapa y contiene datos de tarea
        if (item is Map) {
          var tarea = Task.fromJson(item);
          tareas.add(tarea);
        }
      }
    } else {
      print('Datos no válidos');
    }
  } catch (e) {
    print("Error: $e");
  }

  return tareas;
}

Future<String?> getCalendarOption(String key) async {
  String option = '';

  try {
    DataSnapshot usuario = await _userRegistered.child(key).get();

    if (usuario.exists) {
      option = (usuario.value as Map)["CalendarOption"];
      print("El usuario es $option");
    } else {
      print("El usuario no existe");
    }
  } catch (e) {
    print("Error: $e");
  }

  return option;
}

 setCalendarOption(String key, String option) async {
    final DatabaseReference _userRegistered = FirebaseDatabase(
        databaseURL:
            "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
    .ref()
    .child("Usuarios2") 
    .child("DatosUsuario")
    .child(key);
  //final fcmToken = await FirebaseMessaging.instance.getToken();

  try {
    await _userRegistered.update({
      "CalendarOption": option,
    });
  } catch (e) {
    print(e);
  }
  }
