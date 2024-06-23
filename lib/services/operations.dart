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
    DataSnapshot users = await _userRegistered.get();

    if (users.exists) {
      for (var user in users.children) {
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
    DataSnapshot user = await _userRegistered.child(key).get();

    if (user.exists) {
      name = (user.value as Map)["Nombre"];
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


///Gets the calender option that the user has choosen from the database
Future<String?> getCalendarOption(String key) async {
  String option = '';

  try {
    DataSnapshot user = await _userRegistered.child(key).get();

    if (user.exists) {
      
      if((user.value as Map)["CalendarOption"] != null){
        option = (user.value as Map)["CalendarOption"];
      }else{
        option = "1";
      }
      
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
