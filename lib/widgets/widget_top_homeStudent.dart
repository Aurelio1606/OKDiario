import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/screens/home_estudent.dart';
import 'package:proyecto/screens/main_screen.dart';
import 'package:proyecto/screens/videos.dart';

class TopBarStudentHome extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final bool arrow;
  final int backIndex;

  const TopBarStudentHome({super.key, required this.arrow, required this.backIndex})
      : preferredSize = const Size.fromHeight(120.0);

  Route customChangeView() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            StudentView(
              page: backIndex,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1, 0); // de izquierda a derecha
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 500) //any duration you want
        );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 10,
      toolbarHeight: 120,
      automaticallyImplyLeading: false,
      leadingWidth: 100,
      leading: arrow
          ? IconButton(
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              padding: const EdgeInsets.only(top: 25, left: 5),
              icon: Column(
                children: <Widget>[
                  const Icon(
                    Icons.arrow_back,
                    size: 60,
                    color: Colors.black,
                  ),
                  Transform.translate(
                    offset: const Offset(3, 0),
                    child: const Text(
                      'VOLVER',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.of(context).push(customChangeView());
              },
            )
          : IconButton(
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              padding: const EdgeInsets.only(top: 25, left: 5),
              icon: Column(
                children: <Widget>[
                  const Icon(
                    Icons.power_settings_new_outlined,
                    size: 60,
                    color: Colors.black,
                  ),
                  Transform.translate(
                    offset: const Offset(3, 0),
                    child: const Text(
                      'SALIR',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                NavigatorState navigator = Navigator.of(context);
                navigator.push(MaterialPageRoute(builder: (context) {
                  return const MainScreen();
                }));
              },
            ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            right: 10.0,
          ),
          child: IconButton(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            padding: const EdgeInsets.only(top: 25, left: 10),
            icon: Column(
              children: <Widget>[
                const Icon(
                  Icons.play_circle_outline_rounded,
                  size: 60,
                  color: Colors.black,
                ),
                Transform.translate(
                  offset: const Offset(0, 3),
                  child: const Text(
                    'AYUDA',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                ),
              ],
            ),
            onPressed: () {
              NavigatorState navigator = Navigator.of(context);
              navigator.push(MaterialPageRoute(builder: (context) {
                return Videos();
              }));
            },
          ),
        )
      ],
      title: const Text(
        'AGENDA',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      ),
      centerTitle: true,
      backgroundColor: Color.fromARGB(255, 157, 151, 202),
    );
  }
}
