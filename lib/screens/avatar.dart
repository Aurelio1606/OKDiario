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
  ///User's current puntuation
  int totalPoints = 0;
  ///User's avaible avatars
  List<bool> selected = [];
  ///Index of user's current avatar
  int? currentSelected;

  @override
  void initState() {
    //Initialization of [currentSelected] with user's current avatar
    if (widget.avatarSelected >= 0) {
      currentSelected = widget.avatarSelected;
    } else {
      currentSelected = null;
    }
    super.initState();
  }

  ///Gets user unlocked avatars from database and returns them as a list
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

    //In case user has no unlock avatars, -1 is added to the list to avoid flickering
    //If user has avatars, a list is returned with the avatars indexes
    //Database can return a list (if indexes are continuos) or a map (if indexes are discontinous)
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
          index.add(value['Indice']);
        });
      }
    }

    return index;
  }

  ///Updates user's puntuation in the database
  updateTotalPoints(String userKey, int updatePoints) async {
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

  ///Gets user's puntuation from the database and returns it
  getTotalPoints(String userKey) async {
    final DatabaseReference _totalPoints = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey);

    //Listens for user's puntuation changes
    _totalPoints.onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        if ((snapshot.value as Map)['PuntosTotal'] != null) {
          var newPoints = (snapshot.value as Map)['PuntosTotal'];
          //Use of 'if' to avoid set state to excute multiple times
          if (newPoints != totalPoints && mounted) {
            setState(() {
              totalPoints = (snapshot.value as Map)['PuntosTotal'];
            });
          }
        }
      }
    });
  }

  ///Shows an alert dialog to confirm if user want to buy a certain avatar
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

    //'Continuar' button. If the user press it, their score will be updated and 
    //the avatar will be add to the unlocked list in the database
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
        updateTotalPoints(userKey, resta);

        _avatars.child(index.toString()).update({
          'Indice': index,
          'Desbloqueado': true,
        });
        setState(() {});
        Navigator.of(context, rootNavigator: true)
            .pop(); //close the AlertDialog
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
                //Confirmation message to make sure the user want that avatar
                TextSpan(
                    text:
                        "Seguro que quieres desbloquear este avatar por $precio  ",
                    style: const TextStyle(color: Colors.black, fontSize: 18)),
                WidgetSpan(
                  alignment: PlaceholderAlignment.bottom,
                  child: Transform.translate(
                    offset: const Offset(0, 3),
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
  
  ///Shows and alert dialog when the user has not enough points to buy an avatar
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
            .pop(); //close the AlertDialog
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
                    offset: const Offset(0, 3),
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

  ///Widget that returns a grid with all available avatars in the app from database and the ones that the user has unlocked
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
        //StreamBuilder to obtain all available avatars and their price
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

            while (selected.length < map['Properties']?.length) {
              selected.add(false);
            }

            getUnlockAvatars(userKey);

            return FutureBuilder(
                //Future builder to get the user's unlocked avatars 
                future: getUnlockAvatars(
                    userKey), 
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  //If it has data(-1 is added to avoid flickering, if it was empty there would be flickering)
                  if (snapshot.hasData) {
                    //-1 is used to filter, if it is -1 there will be no data and so we skip the for to avoid an error
                    if (snapshot.data[0] != -1) {
                      for (int i = 0; i < (snapshot.data as List).length; i++) {
                        //For each unlocked avatar we put it on the map of all avatars to true
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
                              //If user tap on the image and the avatar is unlocked
                              //it is selected and saved in the database
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
                                  //shows avatars's image that are not unlocked 
                                  //in this case a lock appears to show it is not unlocked
                                  if (!map['Properties'][index]['Desbloqueado'])
                                    Expanded(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.network(
                                            map['Properties'][index]['Enlace'],
                                            //makes it a little transparent
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
                                  //shows avatars's image that are unlocked
                                  //in this case there is no lock to show it is unlock
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
                                                          //If user tap on the checkbox and the avatar is unlocked
                                                          //it is selected and saved in the database
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
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  const Color.fromARGB(
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
                                          //If user tap on the button and the avatar is not unlocked
                                          //it is selected and saved in the database
                                          if (!map['Properties'][index]
                                              ['Desbloqueado']) {
                                            //If it is not unlocked and has enough points shows an alert dialog
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
                                            } else { //if user has no enough points
                                              showNotPoints(context);
                                            }
                                          } else {
                                            //If user tap on the button and the avatar is unlocked
                                          //it is selected and saved in the database
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
                                              //shows a different text depending on wheter the avatar is unlocked or not
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
                    return const CircularProgressIndicator();
                  }
                });
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  @override
  //build avatars's shop interface
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
              future: getTotalPoints(userProvider.userKey),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue[200],
                        border: Border.all(color: Colors.black)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //* Mi puntuacion
                        //Section with user puntuation
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
                                  style: const TextStyle(fontSize: 17),
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
