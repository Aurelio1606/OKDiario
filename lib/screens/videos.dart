import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/screens/provider.dart';
import 'package:proyecto/screens/video_saver.dart';
import 'package:proyecto/widgets/widget_top_homeStudent.dart';
import 'package:video_player/video_player.dart';

class Videos extends StatefulWidget {
  const Videos({super.key});

  @override
  State<Videos> createState() => _Videos();
}

class _Videos extends State<Videos> {
  ///videos's controllers list
  late List<VideoPlayerController> controllers = [];
  ///videos's titles list
  late List<String> videoTitles = [];
  ///videos's keys list
  late List<String> videoKeys = [];
  File? galleryFile;
  final picker = ImagePicker();

  ///Displays a menu to pick files from the device gallery. It opens the video_saver screen
  void showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 245, 239, 216),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    border: Border.all(width: 1)),
                child: ListTile(
                  visualDensity: const VisualDensity(vertical: 4),
                  leading: const Icon(Icons.photo_library),
                  title: const Text(
                    'Video de la galeria',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    //Redirects user to video saver screen
                    Navigator.push<Widget>(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => const VideoSaver()),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ///Gets videos's urls from the database and returns a map if 'value' is not empty
  getUrls() async {
    UserProvider userProvider = UserProvider();
    final DatabaseReference _videos = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userProvider.userKey)
        .child("Videos");

    DataSnapshot snapshot = await _videos.get();

    if (snapshot.value != null) {
      return (snapshot.value as Map);
    } else {
      return snapshot.value;
    }
  }

  @override
  void initState() {
    super.initState();

    //for each video, gets the video url and then it adds them to the controller list,
    //the titles are added to videoTitles list and the keys are added to
    //videoKeys list, so that for the first video, every variable is added in the same position 
    //in each list
    getUrls().then((results) {
      if (results != null) {
        for (var key in results.keys) {
          controllers.add(VideoPlayerController.networkUrl(
              Uri.parse(results[key]['Enlace']))
            ..initialize().then((_) {
              setState(() {});
            }));
          videoTitles.add(results[key]['Titulo']);
          videoKeys.add(key);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    //disposes each video controller
    for (var controller in controllers) {
      controller.dispose();
    }
  }

  ///Builds the videos grid interface
  Widget getVideos(String userKey) {
    return Expanded(
        child: GridView.builder(
            itemCount: controllers.length,
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    //controllers list to play or pause each video
                    controllers[index].value.isPlaying
                        ? controllers[index].pause()
                        : controllers[index].play();
                  });
                },
                //Cards interface where each video is displayed along with its title
                child: Card(
                  color: const Color.fromARGB(255, 240, 240, 240),
                  margin:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 40, top: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: AspectRatio(
                          aspectRatio: controllers[index].value.aspectRatio,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(children: [
                              controllers[index].value.isInitialized
                                  ? VideoPlayer(controllers[index])
                                  : Container(),
                              Icon(
                                controllers[index].value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: 40,
                              ),
                            ]),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(
                            flex: 3,
                          ),
                          Text(
                            videoTitles[index],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(
                            flex: 2,
                          ),
                          //Button to delete a video
                          IconButton(
                            onPressed: () {
                              showDelete(context, index, userKey);
                            },
                            icon: const Icon(
                              Icons.delete,
                              size: 35,
                              color: Color.fromARGB(255, 207, 112, 106),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  @override
  //Builds the screen where the videos grid is displayed
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: const TopBarStudentHome(
        arrow: true,
        backIndex: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Container(
        width: 70,
        height: 70,
        child: FittedBox(
          //Button to add a video
          child: FloatingActionButton(
            onPressed: () async {
              showPicker(context);
            },
            backgroundColor: const Color.fromARGB(255, 231, 231, 231),
            child: const Column(
              children: [
                Icon(
                  Icons.add,
                  color: Color.fromARGB(255, 64, 158, 235),
                  size: 30,
                ),
                Text(
                  "Añadir",
                  style: TextStyle(color: Colors.black, fontSize: 13),
                )
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 245, 239, 216),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                  color: Colors.blue[200],
                  border: Border.all(color: Colors.black)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Screen title
                  Text(
                    "Mis videos de instrucciones",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
          ),
          getVideos(userProvider.userKey),
        ],
      ),
    );
  }

  ///Shows an alert dialog to confirm if user wants to delete a video
  showDelete(BuildContext context, int index, String userKey) {
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
        final DatabaseReference _deleteVideo = FirebaseDatabase(
                databaseURL:
                    "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
            .ref()
            .child("Usuarios2")
            .child("DatosUsuario")
            .child(userKey)
            .child("Videos");

          //If the user clicks on 'Continuar' button, it removes the video from the database
          //and deletes the video information from controllers, videoTitles and videoKeys lists
        _deleteVideo.child(videoKeys[index]).remove().then((_) {
          setState(() {
            controllers.removeAt(index);
            videoTitles.removeAt(index);
            videoKeys.removeAt(index);
          });
        });
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget cancelButton = ElevatedButton(
      style: const ButtonStyle(
        backgroundColor:
            MaterialStatePropertyAll(Color.fromARGB(255, 157, 151, 202)),
      ),
      child: const Text(
        "Cancelar",
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
      onPressed: () async {
        Navigator.of(context, rootNavigator: true)
            .pop(); //Close the AlertDialog
      },
    );

    AlertDialog alert = AlertDialog(
      contentPadding: const EdgeInsets.only(left: 0, right: 0, top: 10),
      insetPadding: const EdgeInsets.all(10),
      backgroundColor: const Color.fromARGB(255, 231, 231, 231),
      surfaceTintColor: Colors.transparent,
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "¿Quieres borrar este video?",
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
      actions: [
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            continueButton,
            const SizedBox(width: 10,),
            cancelButton,
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
}
