import 'package:flutter/material.dart';
import 'package:proyecto/screens/login.dart';
import 'package:proyecto/screens/register.dart';
import 'package:proyecto/widgets/widget_top_initial.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: const TopBarInitial(arrow: false,),
          backgroundColor: const Color.fromARGB(255, 245, 239, 216),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(5),
                      alignment: Alignment.center,
                      minimumSize:
                          MaterialStateProperty.all(const Size(250, 80)),
                      backgroundColor: MaterialStateProperty.all(
                          Color.fromARGB(255, 153, 147, 199)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                      side: MaterialStateProperty.all(
                        const BorderSide(
                          width: 1.5,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    onPressed: () {
                      NavigatorState navigator = Navigator.of(context);
                      navigator.push(MaterialPageRoute(builder: (context) {
                        return const Login();
                      }));
                    },
                    child: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        height: 2,
                        width: 150,
                        color: Colors.black,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("O"),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        height: 2,
                        width: 150,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 100,
                ),
                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(5),
                      alignment: Alignment.center,
                      minimumSize:
                          MaterialStateProperty.all(const Size(250, 80)),
                      backgroundColor: MaterialStateProperty.all(
                          Color.fromARGB(255, 153, 147, 199)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                      side: MaterialStateProperty.all(
                        const BorderSide(
                          width: 1.5,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    onPressed: () {
                      NavigatorState navigator = Navigator.of(context);
                      navigator.push(MaterialPageRoute(builder: (context) {
                        return const Register();
                      }));
                    },
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
