import 'package:flutter/material.dart';
import 'package:proyecto/screens/main_screen.dart';

class TopBarHome extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final bool arrow;

  const TopBarHome({super.key, required this.arrow})
      : preferredSize = const Size.fromHeight(120.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 10,
      toolbarHeight: 120,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10.0,),
          child: IconButton(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            padding: const EdgeInsets.only(top: 25, left: 10),
            icon: Column(
              children: <Widget>[
                const Icon(
                  Icons.power_settings_new_outlined,
                  size: 60,
                  color: Colors.black,
                ),
                Transform.translate(
                  offset: const Offset(0, 3),
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
