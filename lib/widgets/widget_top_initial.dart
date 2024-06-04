import 'package:flutter/material.dart';
import 'package:proyecto/screens/home_selection.dart';

class TopBarInitial extends StatefulWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final bool arrow;

  const TopBarInitial(
      {super.key, required this.arrow})
      : preferredSize = const Size.fromHeight(120.0);

  @override
  State<TopBarInitial> createState() => _TopBarInitialState();
}

class _TopBarInitialState extends State<TopBarInitial> {
  @override
  //Builds top bar interface for the main screen (first screen that apperar when the users open the app)
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 10,
      toolbarHeight: 120,
      automaticallyImplyLeading: false,
      leadingWidth: 100,
      leading: (widget.arrow)
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
                    offset: const Offset(0, 3),
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
                NavigatorState navigator = Navigator.of(context);
                navigator.push(MaterialPageRoute(builder: (context) {
                  return const HomeSelection();
                }));
              },
            )
          : Container(),
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
