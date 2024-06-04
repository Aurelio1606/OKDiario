import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

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


// Future<List<Student>> getUsuarios() async {
//   List<Student> estudiantes = [];

//   try {
//     // Obtener el DatabaseEvent usando onValue
//     DatabaseEvent event = await _userRef.onValue.first;

//     // Obtener el DataSnapshot desde el evento
//     DataSnapshot dataSnapshot = event.snapshot;

//     final data = dataSnapshot.value;

//     // Verificar si hay datos y si es una lista
//     if (data != null && data is List) {
//       // Realizar un casting a List<dynamic>
//       final lista = data;

//       // Iterar sobre los elementos de la lista
//       for (var item in lista) {
//         var estudiante = Student.fromJson(item);
//         estudiantes.add(estudiante);
//       }
//     } else {
//       print('Datos no válidos');
//     }
//   } catch (e) {
//     print("Error: $e");
//   }

//   return estudiantes;
// }

///Registers an user, saving its data in the databse
Future<void> userRegister(
    String name, String second, String password, String email) async {
  String key = _userRegistered.push().key!;

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

///Checks if the user name [name] and password [password] introduced by the user in login screen
///is the same as the ones stored in the database
Future<String?> validateData(String name, String password) async {
  String? key = '';

  try {
    DataSnapshot usuarios = await _userRegistered.get();

    if (usuarios.exists) {
      for (var user in usuarios.children) {
        if ((user.value as Map)["Nombre"] == name &&
            (user.value as Map)["Contraseña"] == password) {
          key = user.key;

          return key;
        } else {
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

///Gets the user's name using the user key
Future<String?> getUser(String key) async {
  String name = '';

  try {
    DataSnapshot usuario = await _userRegistered.child(key).get();

    if (usuario.exists) {
      name = (usuario.value as Map)["Nombre"];
    } else {
      print("El usuario no existe");
    }
  } catch (e) {
    print("Error: $e");
  }

  return name;
}

///Saves in the database activity information about the user and the time 
///at which the action was performed
Future<void> registerActivity(String userkey, String activity) async {
  String? user = await getUser(userkey);

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

// Future<List<Task>> getTareas(String userkey) async {
//   final DatabaseReference _userTasks = FirebaseDatabase(
//           databaseURL:
//               "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
//       .ref()
//       .child("Usuarios2")
//       .child("DatosUsuario")
//       .child(userkey)
//       .child("TaskData");

//   List<Task> tareas = [];

//   try {
//     // Obtener el DatabaseEvent usando onValue
//     DatabaseEvent event = await _userTasks.onValue.first;

//     // Obtener el DataSnapshot desde el evento
//     DataSnapshot dataSnapshot = event.snapshot;

//     final data = dataSnapshot.value;

//     // Verificar si hay datos y si es una lista
//     if (data != null && data is List) {
//       // Iterar sobre los elementos de la lista
//       for (var item in data) {
//         // Verificar si el elemento es un mapa y contiene datos de tarea
//         if (item is Map) {
//           var tarea = Task.fromJson(item);
//           tareas.add(tarea);
//         }
//       }
//     } else {
//       print('Datos no válidos');
//     }
//   } catch (e) {
//     print("Error: $e");
//   }

//   return tareas;
// }

///Gets the calender option that the user has choosen from the database
Future<String?> getCalendarOption(String key) async {
  String option = '';

  try {
    DataSnapshot usuario = await _userRegistered.child(key).get();

    if (usuario.exists) {
      option = (usuario.value as Map)["CalendarOption"];
    } else {
      print("El usuario no existe");
    }
  } catch (e) {
    print("Error: $e");
  }

  return option;
}

///Changes the user's calendar option in the database
setCalendarOption(String key, String option) async {
    final DatabaseReference _userRegistered = FirebaseDatabase(
        databaseURL:
            "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
    .ref()
    .child("Usuarios2") 
    .child("DatosUsuario")
    .child(key);

  try {
    await _userRegistered.update({
      "CalendarOption": option,
    });
  } catch (e) {
    print(e);
  }
  }
