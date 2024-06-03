import 'package:flutter/material.dart';
import 'package:proyecto/screens/home_selection.dart';
import 'package:proyecto/screens/provider.dart';
import 'package:proyecto/services/operations.dart';
import 'package:proyecto/services/snackBar.dart';
import 'package:proyecto/widgets/widget_top_login.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController userName = TextEditingController();
  TextEditingController password = TextEditingController();
  bool visible = true;

  @override
  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    userName.dispose();
    password.dispose();

    super.dispose();
  }

  ///Get user's name and password stored in the device so they only have to enter the name
  ///and password the first time
  void loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    userName.text = prefs.getString('Usuario') ?? '';
    password.text = prefs.getString('Contraseña') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    SnackBarService snackBarService = SnackBarService();
    return MaterialApp(
        scaffoldMessengerKey: snackBarService.scaffoldKey,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: const TopBarLogin(
            arrow: true,
          ),
          backgroundColor: const Color.fromARGB(255, 245, 239, 216),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: userName,
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
                      labelStyle: const TextStyle(color: Colors.black),
                      hintText: 'Nombre de usuario',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: password,
                    decoration: InputDecoration(
                      labelText: 'contraseña',
                      labelStyle: const TextStyle(color: Colors.black),
                      hintText: 'contraseña',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      //Allow user to show or hide the password
                      suffixIcon: IconButton(
                        icon: visible
                            ? const Icon(Icons.visibility_off)
                            : const Icon(Icons.visibility),
                        onPressed: () {
                          setState(() {
                            visible = !visible;
                          });
                        },
                      ),
                    ),
                    obscureText: visible,
                  ),
                ),
                const SizedBox(
                  height: 70,
                ),
                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(5),
                      alignment: Alignment.center,
                      minimumSize:
                          MaterialStateProperty.all(const Size(250, 80)),
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 153, 147, 199)),
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
                    onPressed: () async {
                      showDialog(
                        context: context,
                        barrierDismissible:
                            false, //Prevent the user from closing the dialog by tapping outside of it
                        builder: (BuildContext context) {
                          return const Center(
                            child:
                                CircularProgressIndicator(), //Charge indicator
                          );
                        },
                      );

                      try {
                        String? key = await validateData(
                          userName.text.toLowerCase().trim(),
                          password.text.toLowerCase().trim(),
                        );

                        if (context.mounted && key!.isNotEmpty) {
                          var token =
                              Provider.of<UserProvider>(context, listen: false);
                          token.setUserKey(key);

                          await registerActivity(
                              token.userKey, "Inicio de sesion");

                          if (token.userKey.isNotEmpty) {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            
                            //Saves user's name and password in the device's sharedPreferences
                            prefs.setString(
                                'Usuario', userName.text.toLowerCase().trim());
                            prefs.setString('Contraseña',
                                password.text.toLowerCase().trim());

                            //gets achivement day stored in the device
                            var now = DateTime.now();
                            DateTime achivementDate = DateTime(
                              now.year,
                              prefs.getInt('LogroMes') ?? now.month,
                              prefs.getInt('LogroDia') ?? now.day,
                            );

                            //if achivement day is equal to current day, it increases the number of times the user logs in
                            if (achivementDate.day == now.day) {
                              var numLogins = prefs.getInt('NumLogins') ?? 1;
                              prefs.setInt('NumLogins', numLogins += 1);
                            }

                            //Simulate 500 miliseconds delay
                            await Future.delayed(
                                const Duration(milliseconds: 500));

                            //Close charge indicator
                            Navigator.of(context, rootNavigator: true).pop();

                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return const HomeSelection();
                            }));
                          }
                        } else {
                          if (context.mounted) {
                            //shows an alert if user name or password is incorrect
                            snackBarService.showSnackBar(
                                content: "Usuario o contraseña incorrecta");
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                        }
                      } catch (error) {
                        print("Errorrrr: $error");
                        // Cerrar el indicador de carga en caso de error
                        if (context.mounted) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                      }
                    },
                    child: const Text(
                      'Iniciar Sesión',
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
