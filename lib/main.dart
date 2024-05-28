import 'package:dcdg/dcdg.dart';

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:proyecto/models/students_model.dart';
import 'package:proyecto/screens/main_screen.dart';
import 'package:proyecto/screens/provider.dart';
import 'package:proyecto/services/notifications.dart';
//import 'package:proyecto/services/operations.dart';
import 'package:timezone/data/latest.dart' as tz;
//import 'package:timezone/timezone.dart' as tz;

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  NotificationService().initNotifications();
  tz.initializeTimeZones();

  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyBi8T1K6zfEDHbMzC1xe2JhgHAJZUlUndo",
            appId: "1:768293741186:android:6274db0fa804765c01ca9b",
            messagingSenderId: "768293741186",
            projectId: "prueba-76a0b",
          ),
        )
      : await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          SfGlobalLocalizations.delegate,
          
        ],
        supportedLocales: const [
           Locale('es'),
        ],
        locale: const Locale('es'),
        title: 'Prueba',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MainScreen(),
      ),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   TextEditingController userName = TextEditingController();
//   TextEditingController password = TextEditingController();
//   bool visible = false;
//   late Student user;
//   late DatabaseReference usuarios;
//   List<Student> estudiantes = [];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.title,
//         ),
//       ),
//       body: Container(
//         child: Column(
//           children: [
//             const SizedBox(
//               height: 160.0,
//             ),
//             TextField(
//               controller: userName,
//               decoration: InputDecoration(
//                 labelText: 'Nombre de usuario',
//                 labelStyle: const TextStyle(color: Colors.black),
//                 hintText: 'Nombre de usuario',
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: const BorderSide(
//                     color: Colors.black,
//                     width: 2,
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(
//               height: 20.0,
//             ),

//             ElevatedButton(
//               style: ButtonStyle(
//                 elevation: MaterialStateProperty.all(5),
//                 alignment: Alignment.center,
//                 minimumSize: MaterialStateProperty.all(const Size(200, 40)),
//                 backgroundColor: MaterialStateProperty.all(
//                     const Color.fromARGB(134, 238, 238, 238)),
//                 shape: MaterialStateProperty.all(RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5.0),
//                 )),
//                 side: MaterialStateProperty.all(
//                   const BorderSide(
//                     width: 1.5,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               onPressed: () async {
//                 print(userName.text);
//               },
//               child: const Text(
//                 'Guardar',
//                 style: TextStyle(color: Colors.black, fontSize: 20),
//               ),
//             ),

//             const SizedBox(
//               height: 100.0,
//             ),

//             TextField(
//               controller: password,
//               decoration: InputDecoration(
//                 labelText: 'Contraseña',
//                 labelStyle: const TextStyle(color: Colors.black),
//                 hintText: 'Contraseña',
//                 //errorText: 'contraseña incorrecta',
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: const BorderSide(
//                     color: Colors.black,
//                     width: 2,
//                   ),
//                 ),
//                 suffixIcon: IconButton(
//                   icon: visible
//                       ? const Icon(Icons.visibility_off)
//                       : const Icon(Icons.visibility),
//                   onPressed: () {
//                     setState(() {
//                       visible = !visible;
//                     });
//                   },
//                 ),
//               ),
//               obscureText: visible,
//             ),
//             // if ()
//             //   Text(
//             //     'Contraseña incorrecta. Intentalo de nuevo',
//             //     style: TextStyle(color: const Color(0xFFBF1717).withOpacity(0.8)),
//             //   ),
//             ElevatedButton(
//               style: ButtonStyle(
//                 elevation: MaterialStateProperty.all(5),
//                 alignment: Alignment.center,
//                 minimumSize: MaterialStateProperty.all(const Size(200, 40)),
//                 backgroundColor: MaterialStateProperty.all(
//                     const Color.fromARGB(134, 238, 238, 238)),
//                 shape: MaterialStateProperty.all(RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5.0),
//                 )),
//                 side: MaterialStateProperty.all(
//                   const BorderSide(
//                     width: 1.5,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               onPressed: () async {
//                 user = Student(userName.text, password.text);
//                 guardarUsuarios(user);
//                 //print(password.text);

//                 estudiantes = await getUsuarios();
//                 estudiantes.forEach((element) {
//                   print("Nombre: " +
//                       element.name +
//                       "\nTelefono: " +
//                       element.phone);
//                 });
//               },
//               child: const Text(
//                 'Guardar',
//                 style: TextStyle(color: Colors.black, fontSize: 20),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
