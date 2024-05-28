import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/screens/main_screen.dart';
import 'package:proyecto/screens/provider.dart';
import 'package:proyecto/services/notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

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

/// Clase Main//

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
