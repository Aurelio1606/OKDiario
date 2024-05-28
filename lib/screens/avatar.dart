import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/screens/provider.dart';
import 'package:proyecto/widgets/widget_top_homeStudent.dart';

class Avatar extends StatefulWidget {
  final int avatarSelected;

  const Avatar({super.key, required this.avatarSelected});

  @override
  _Avatar createState() => _Avatar();
}

class _Avatar extends State<Avatar> {
  int totalPoints = 0;
  List<bool> seleccionado = [];
  int? currentSelected;

  @override
  void initState() {
    if (widget.avatarSelected >= 0) {
      currentSelected = widget.avatarSelected;
    } else {
      currentSelected = null;
    }
    super.initState();
  }

//Funcion que devuelve una lista con los avatares desbloqueados

  getUnlockAvatars(String userKey) async {

    final Query _unlockAvatars = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey)
        .child("Avatar");

    DataSnapshot snapshot = await _unlockAvatars.get();
    List index = [];

    /**
     * En caso de que el usuario no tenga avatares, se incluye -1 a la lista
     * (para evitar flickering en la lista de avatares)
     * Si tienes avatares, se devuelve una lista con los indices de los avatares
     */

    if (snapshot.value == null) {
      index.add(-1);
    } else {
      index.clear();
      if (snapshot.value is List) {
        (snapshot.value as List)
            .where((element) => element != null)
            .forEach((element) {
          index.add(element['Indice']);
        });
      } else {
        (snapshot.value as Map).forEach((key, value) {
          print(value['Indice']);
          index.add(value['Indice']);
        });
      }
    }

    return index;
  }

  updatePuntosTotales(String userKey, int updatePoints) async {
    final DatabaseReference _updateTotalPoints = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey);

    _updateTotalPoints.update({
      'PuntosTotal': updatePoints,
    });
  }

  getPuntosTotales(String userKey) async {
    final DatabaseReference _totalPoints = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey);

    _totalPoints.onValue.listen((event) {
      var snapshot = event.snapshot;
      //print((snapshot.value as Map)['PuntosTotal']);
      if (snapshot.value != null) {
        if ((snapshot.value as Map)['PuntosTotal'] != null) {
          var newPoints = (snapshot.value as Map)['PuntosTotal'];
          if (newPoints != totalPoints && mounted) {
            //If para evitar que se ejecute multiples veces el set state
            setState(() {
              totalPoints = (snapshot.value as Map)['PuntosTotal'];
            });
          }
        }
      }
    });
  }

  showBuyConfirmation(BuildContext context, String index, String userKey,
      String enlace, int precio) {
    final DatabaseReference _avatars = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey)
        .child("Avatar");

    Widget continueButton = ElevatedButton(
      style: const ButtonStyle(
        backgroundColor:
            MaterialStatePropertyAll(Color.fromARGB(255, 157, 151, 202)),
      ),
      child: const Text(
        "Continuar",
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
      onPressed: () async {
        int resta = totalPoints - precio;
        updatePuntosTotales(userKey, resta);

        _avatars.child(index.toString()).update({
          'Indice': index,
          'Desbloqueado': true,
        });
        setState(() {});
        Navigator.of(context, rootNavigator: true)
            .pop(); // Cerrar el AlertDialog
      },
    );

    AlertDialog alert = AlertDialog(
      contentPadding: const EdgeInsets.only(left: 25, right: 25, top: 20),
      backgroundColor: const Color.fromARGB(255, 231, 231, 231),
      surfaceTintColor: Colors.transparent,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text:
                        "Seguro que quieres desbloquear este avatar por $precio  ",
                    style: TextStyle(color: Colors.black, fontSize: 18)),
                WidgetSpan(
                  alignment: PlaceholderAlignment.bottom,
                  child: Transform.translate(
                    offset: Offset(0, 3),
                    child: Image.asset(
                      'assets/images/estrella.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Image.network(
            enlace,
            width: 150,
            height: 150,
          ),
        ],
      ),
      actions: [
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            continueButton,
          ],
        )
      ],
    );

    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showNotPoints(BuildContext context) {
    Widget continueButton = ElevatedButton(
      style: const ButtonStyle(
        backgroundColor:
            MaterialStatePropertyAll(Color.fromARGB(255, 157, 151, 202)),
      ),
      child: const Text(
        "Cerrar",
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
      onPressed: () async {
        Navigator.of(context, rootNavigator: true)
            .pop(); // Cerrar el AlertDialog
      },
    );

    AlertDialog alert = AlertDialog(
      contentPadding: const EdgeInsets.only(left: 25, right: 25, top: 20),
      backgroundColor: const Color.fromARGB(255, 231, 231, 231),
      surfaceTintColor: Colors.transparent,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                    text: "No tienes suficientes  ",
                    style: TextStyle(color: Colors.black, fontSize: 18)),
                WidgetSpan(
                  alignment: PlaceholderAlignment.bottom,
                  child: Transform.translate(
                    offset: Offset(0, 3),
                    child: Image.asset(
                      'assets/images/estrella.png',
                      width: 30,
                      height: 30,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
      actions: [
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            continueButton,
          ],
        )
      ],
    );

    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget getAvatar(String userKey) {
    final DatabaseReference _saveAvatar = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey)
        .child("AvatarSeleccionado");

    return StreamBuilder(
        //StreamBuilder para obtener todos los avatares disponibles y su precio
        stream: FirebaseDatabase(
                databaseURL:
                    "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
            .ref()
            .child("Usuarios2")
            .child("Avatares")
            .onValue,
        builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasData) {
            Map map = {};
            map['Properties'] = snapshot.data!.snapshot.value;
            map['Key'] = snapshot.data!.snapshot.key;

            while (seleccionado.length < map['Properties']?.length) {
              seleccionado.add(false);
            }

            getUnlockAvatars(userKey);

            return FutureBuilder(
                //Future builder para obtener los avatares desbloqueados de cada usuario
                future: getUnlockAvatars(
                    userKey), //Funcion que devuelve una lista de los avatares desbloquedos
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  //Si tiene datos (se añade el -1 para evitar el flickerin en este paso, si no tuviera nada habria flickering)
                  if (snapshot.hasData) {
                    //Utilizamos el menos -1 para filtrar, si es -1 quiere decir que no hay datos
                    //y por lo tanto no se hace el for, ya que si no da error
                    //print(snapshot.data);
                    if (snapshot.data[0] != -1) {
                      for (int i = 0; i < (snapshot.data as List).length; i++) {
                        // para cada avatar desbloqueado lo ponemos en el mapa de todos los avatares a true
                        map['Properties'][int.parse(snapshot.data[i])]
                            ['Desbloqueado'] = true;
                      }
                    }

                    return Expanded(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2),
                        itemCount: map['Properties']?.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              //Tap si picho en la imagen
                              // print(index);
                              // print(currentSelected);
                              setState(() {
                                if (currentSelected != index &&
                                    map['Properties'][index]['Desbloqueado']) {
                                  currentSelected = index;
                                  _saveAvatar.update({
                                    'Indice': index,
                                    'Enlace': map['Properties'][index]
                                        ['Enlace'],
                                  });
                                } else {
                                  currentSelected = null;
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (!map['Properties'][index]['Desbloqueado'])
                                    Expanded(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.network(
                                            map['Properties'][index]['Enlace'],
                                            opacity:
                                                const AlwaysStoppedAnimation(
                                                    .5),
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Image.asset(
                                              'assets/images/candado.png',
                                              width: 35,
                                              height: 35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (map['Properties'][index]['Desbloqueado'])
                                    Expanded(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Transform.translate(
                                            offset: Offset(10, -5),
                                            child: Align(
                                              alignment: Alignment.topRight,
                                              child: Transform.scale(
                                                scale: 1.4,
                                                child: Checkbox(
                                                    activeColor: Colors.green,
                                                    shape: null,
                                                    value: currentSelected ==
                                                        index,
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        if (value == true) {
                                                          //Tap si pincho en la checkbox
                                                          currentSelected =
                                                              index;
                                                          _saveAvatar.update({
                                                            'Indice': index,
                                                            'Enlace':
                                                                map['Properties']
                                                                        [index]
                                                                    ['Enlace'],
                                                          });
                                                        } else {
                                                          currentSelected =
                                                              null;
                                                        }
                                                      });
                                                    }),
                                              ),
                                            ),
                                          ),
                                          Image.network(
                                            map['Properties'][index]['Enlace'],
                                          ),
                                        ],
                                      ),
                                    ),
                                  Center(
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                          elevation:
                                              MaterialStateProperty.all(5),
                                          // alignment: Alignment.centerLeft,
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Color.fromARGB(
                                                      255, 157, 151, 202)),
                                          shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          )),
                                          side: MaterialStateProperty.all(
                                            const BorderSide(
                                              width: 1.5,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          //Tap si pincho en el boton
                                          if (!map['Properties'][index]
                                              ['Desbloqueado']) {
                                            //si no esta desbloqueado
                                            if (totalPoints >=
                                                map['Properties'][index]
                                                    ['Precio']) {
                                              showBuyConfirmation(
                                                  context,
                                                  index.toString(),
                                                  userKey,
                                                  map['Properties'][index]
                                                      ['Enlace'],
                                                  map['Properties'][index]
                                                      ['Precio']);
                                            } else {
                                              showNotPoints(context);
                                            }
                                          } else {
                                            setState(() {
                                              if (currentSelected != index) {
                                                currentSelected = index;
                                                _saveAvatar.update({
                                                  'Indice': index,
                                                  'Enlace': map['Properties']
                                                      [index]['Enlace'],
                                                });
                                              } else {
                                                currentSelected = null;
                                              }
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: 100,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                !map['Properties'][index]
                                                        ['Desbloqueado']
                                                    ? map['Properties'][index]
                                                            ['Precio']
                                                        .toString()
                                                    : (currentSelected == index
                                                        ? 'Seleccionado'
                                                        : 'Seleccionar'),
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              map['Properties'][index]
                                                      ['Desbloqueado']
                                                  ? Container()
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: Image.asset(
                                                        'assets/images/estrella.png',
                                                        width: 25,
                                                        height: 25,
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                });
          }
          print(snapshot);
          return Center(child: CircularProgressIndicator());
        });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: const TopBarStudentHome(
        arrow: true,
        backIndex: 2,
      ),
      backgroundColor: const Color.fromARGB(255, 245, 239, 216),
      body: Column(
        children: [
          FutureBuilder(
              future: getPuntosTotales(userProvider.userKey),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue[200],
                        //borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //* Mi puntuacion
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: const Text(
                                "Mis puntos",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 17),
                              ),
                            ),
                            const SizedBox(
                              height: 2.5,
                            ),
                            Row(
                              children: [
                                Text(
                                  totalPoints.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 17),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Transform.translate(
                                  offset: const Offset(0, -2),
                                  child: Image.asset(
                                    'assets/images/estrella.png',
                                    width: 23,
                                    height: 23,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          getAvatar(userProvider.userKey),
        ],
      ),
    );
  }
}
