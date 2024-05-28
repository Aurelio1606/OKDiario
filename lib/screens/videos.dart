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
  @override
  _Videos createState() => _Videos();
}

class _Videos extends State<Videos> {
  late List<VideoPlayerController> controllers = [];
  late List<String> videoTitles = [];
  late List<String> videoKeys = [];
  File? galleryFile;
  final picker = ImagePicker();

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
                  visualDensity: VisualDensity(vertical: 4),
                  leading: const Icon(Icons.photo_library),
                  title: const Text(
                    'Video de la galeria',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    // getVideoFromGallery(context);
                    // Navigator.of(context).pop();
                    Navigator.push<Widget>(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => VideoSaver()),
                    );
                  },
                ),
              ),
              // ListTile(
              //   leading: const Icon(Icons.photo_camera),
              //   title: const Text('Video de un enlace'),
              //   onTap: () {
              //     Navigator.push<Widget>(
              //       context,
              //       MaterialPageRoute(
              //           builder: (BuildContext context) => VideoSaver()),
              //     );
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }

  getVideoFromGallery(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final DatabaseReference _saveVideo = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userProvider.userKey)
        .child("Videos");

    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    XFile? xfilePicked = pickedFile;

    if (xfilePicked != null) {
      Container(
        color: const Color.fromARGB(255, 165, 165, 165),
      );
    }
  }

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

    // print((snapshot.value as Map));
    // print((snapshot.value as Map).length);
    if (snapshot.value != null) {
      return (snapshot.value as Map);
    } else {
      return snapshot.value;
    }
  }

  @override
  void initState() {
    super.initState();
    // _controller = VideoPlayerController.networkUrl(Uri.parse(
    //     'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
    //   ..initialize().then((_) {
    //     // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    //     setState(() {});
    //   });

    getUrls().then((results) {
      if (results != null) {
        //setState(() {
        for (var key in results.keys) {
          controllers.add(VideoPlayerController.networkUrl(
              Uri.parse(results[key]['Enlace']))
            ..initialize().then((_) {
              setState(() {});
            }));
          videoTitles.add(results[key]['Titulo']);
          videoKeys.add(key);
        }
        //});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in controllers) {
      controller.dispose();
    }
  }

  Widget getVideos(String userKey) {
    return Expanded(
        child: GridView.builder(
            itemCount: controllers.length,
            shrinkWrap: true,
            physics: ScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    controllers[index].value.isPlaying
                        ? controllers[index].pause()
                        : controllers[index].play();
                  });
                },
                child: Card(
                  color: Color.fromARGB(255, 240, 240, 240),
                  margin:
                      EdgeInsets.only(left: 10, right: 10, bottom: 40, top: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: AspectRatio(
                          //Container
                          //padding: EdgeInsets.all(10),
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
          child: FloatingActionButton(
            onPressed: () async {
              showPicker(context);
            },
            backgroundColor: Color.fromARGB(255, 231, 231, 231),
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
                  //borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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

        //print(videoKeys[index]);
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
            .pop(); // Cerrar el AlertDialog
      },
    );

    AlertDialog alert = AlertDialog(
      contentPadding: const EdgeInsets.only(left: 0, right: 0, top: 10),
      insetPadding: EdgeInsets.all(10),
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
