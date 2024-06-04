import 'package:flutter/material.dart';
import 'package:proyecto/screens/login.dart';
import 'package:proyecto/services/operations.dart';
import 'package:proyecto/services/snackBar.dart';
import 'package:proyecto/widgets/widget_top_login.dart';
import 'package:email_validator/email_validator.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _LoginState();
}

class _LoginState extends State<Register> {
  ///Controller for the user name text field
  TextEditingController userName = TextEditingController();

  ///Controller for the user second name text field
  TextEditingController userSecondName = TextEditingController();

  ///Controller for the user password text field
  TextEditingController password = TextEditingController();

  ///Controller for the user password text field
  TextEditingController repeatPassword = TextEditingController();

  ///Controller for the user email text field
  TextEditingController email = TextEditingController();
  bool visible = true;
  bool visible2 = true;
  bool emailOK = true;
  bool passwordOK = true;

  @override
  void dispose() {
    userName.dispose();
    password.dispose();

    super.dispose();
  }

  @override
  //Builds user registration screen interface
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
                  height: 30,
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
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: userSecondName,
                    decoration: InputDecoration(
                      labelText: 'Apellidos',
                      labelStyle: const TextStyle(color: Colors.black),
                      hintText: 'Apellidos',
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
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: email,
                        decoration: InputDecoration(
                            labelText: 'Correo electrónico',
                            labelStyle: const TextStyle(color: Colors.black),
                            hintText: 'Correo',
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
                            errorText: emailOK
                                ? null
                                : "ERROR EN EL CORREO ELECTRONICO",
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.red.shade200,
                                width: 2,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.red.shade200,
                                width: 2,
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
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
                      errorText:
                          passwordOK ? null : "LAS CONTRASEÑAS NO SON IGUALES",
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.red.shade200,
                          width: 2,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.red.shade200,
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        //Allows user to show or hide the password
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
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: repeatPassword,
                    decoration: InputDecoration(
                      labelText: 'Repetir contraseña',
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
                      //checks if both passwords are the same
                      errorText:
                          passwordOK ? null : "LAS CONTRASEÑAS NO SON IGUALES",
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.red.shade200,
                          width: 2,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.red.shade200,
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        //Allows user to show or hide the password
                        icon: visible2
                            ? const Icon(Icons.visibility_off)
                            : const Icon(Icons.visibility),
                        onPressed: () {
                          setState(() {
                            visible2 = !visible2;
                          });
                        },
                      ),
                    ),
                    obscureText: visible2,
                  ),
                ),
                const SizedBox(
                  height: 30,
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
                      //Checks if the email is valid and if the passwords are the same
                      if (EmailValidator.validate(email.text) &&
                          ((password.text.toLowerCase() ==
                                  repeatPassword.text.toLowerCase()) &&
                              password.text.isNotEmpty)) {
                        await userRegister(
                            userName.text.toLowerCase().trim(),
                            userSecondName.text.toLowerCase().trim(),
                            password.text.toLowerCase().trim(),
                            email.text.toLowerCase().trim());

                        NavigatorState navigator = Navigator.of(context);
                        //Redirects the user to the login screen
                        navigator.push(MaterialPageRoute(builder: (context) {
                          return const Login();
                        }));
                      } else if (userName.text.toLowerCase().trim().isEmpty) {
                        //if the user has not complete the name field shows an alert
                        snackBarService.showSnackBar(
                            content: "PON TU NOMBRE DE USUARIO");
                      } else if (userSecondName.text
                          .toLowerCase()
                          .trim()
                          .isEmpty) {
                        //if the user has not complete the second name field shows an alert
                        snackBarService.showSnackBar(
                            content: "PON TUS APELLIDOS");
                      } else if (!EmailValidator.validate(email.text)) {
                        //if the email is not valid shows an alert
                        snackBarService.showSnackBar(
                            content: "CORREO ELECTRONICO INCORRECTO");
                      } else if ((password.text.toLowerCase() !=
                              repeatPassword.text.toLowerCase()) &&
                          password.text.isNotEmpty) {
                        //if the passwords are not the same shows an alert
                        snackBarService.showSnackBar(
                            content: "LAS CONTRASEÑAS NO SON IGUALES");
                      }
                    },
                    child: const Text(
                      'Registrar',
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
