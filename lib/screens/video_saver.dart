import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/screens/provider.dart';
import 'package:proyecto/screens/videos.dart';
import 'package:proyecto/widgets/widget_top_homeStudent.dart';
import 'package:video_player/video_player.dart';

class VideoSaver extends StatefulWidget {
  const VideoSaver({super.key});

  @override
  State<VideoSaver> createState() => _VideoSaverState();
}

class _VideoSaverState extends State<VideoSaver> {
  TextEditingController url = TextEditingController();
  TextEditingController title = TextEditingController();
  File? galleryFile;
  final picker = ImagePicker();
  bool chargeVideo = false;
  late VideoPlayerController _controller;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  getVideoIndex(String userKey) async {
    final DatabaseReference _videoIndex = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userKey)
        .child("Videos");

    //DataSnapshot snapshot = await _videoIndex.;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 239, 216),
      appBar: TopBarStudentHome(arrow: true, backIndex: 0),
      body: Padding(
        padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              TextField(
                maxLines: 2,
                controller: title,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 190, 190, 190),
                  hintText: 'Escribe el titulo del video',
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
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width - 100,
                child: !chargeVideo
                    ? GestureDetector(
                        onTap: () async {
                          final pickedFile = await picker.pickVideo(
                              source: ImageSource.gallery);
                          XFile? xfilePicked = pickedFile;

                          setState(() {
                            if (xfilePicked != null) {
                              galleryFile = File(pickedFile!.path);
                              print(galleryFile);
                              chargeVideo = true;

                              _controller = VideoPlayerController.networkUrl(
                                  Uri.parse(galleryFile!.path))
                                ..initialize().then((_) {
                                  // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                                  setState(() {});
                                });
                            } else {
                              print("eqweqw");
                            }
                          });
                        },
                        child: Container(
                          decoration:
                              BoxDecoration(border: Border.all(width: 1)),
                          child: const Center(
                              child: Icon(
                            Icons.video_collection,
                            size: 40,
                          )),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });
                        },
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          // decoration:
                          //     BoxDecoration(border: Border.all(width: 1)),
                          child: Stack(
                            children: [
                              VideoPlayer(_controller),
                              Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: 40,
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final pickedFile =
                          await picker.pickVideo(source: ImageSource.gallery);
                      XFile? xfilePicked = pickedFile;

                      setState(() {
                        if (xfilePicked != null) {
                          galleryFile = File(pickedFile!.path);
                          _controller = VideoPlayerController.networkUrl(
                              Uri.parse(galleryFile!.path))
                            ..initialize().then((_) {
                              // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
                              setState(() {});
                            });
                        }
                      });
                    },
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(5),
                      // alignment: Alignment.centerLeft,
                      minimumSize:
                          MaterialStateProperty.all(const Size(150, 60)),
                      backgroundColor: MaterialStateProperty.all(
                          Color.fromARGB(255, 157, 151, 202)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      )),
                      side: MaterialStateProperty.all(
                        const BorderSide(
                          width: 1.5,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Cambiar",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (title.text.isNotEmpty) {
                        final DatabaseReference _saveVideo = FirebaseDatabase(
                                databaseURL:
                                    "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
                            .ref()
                            .child("Usuarios2")
                            .child("DatosUsuario")
                            .child(userProvider.userKey)
                            .child("Videos");

                        _saveVideo.push().set({
                          'Titulo': title.text,
                          'Enlace': galleryFile!.path,
                        });
                        Navigator.push<Widget>(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => Videos()),
                        );
                      }
                    },
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(5),
                      // alignment: Alignment.centerLeft,
                      minimumSize:
                          MaterialStateProperty.all(const Size(150, 60)),
                      backgroundColor: MaterialStateProperty.all(
                          Color.fromARGB(255, 157, 151, 202)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      )),
                      side: MaterialStateProperty.all(
                        const BorderSide(
                          width: 1.5,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Guardar",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ],
              ),
              // TextField(
              //   maxLines: 3,
              //   controller: url,
              //   decoration: InputDecoration(
              //     filled: true,
              //     fillColor: const Color.fromARGB(255, 190, 190, 190),
              //     hintText: 'Escribe su enlace',
              //     enabledBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(16),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(16),
              //       borderSide: const BorderSide(
              //         color: Colors.black,
              //         width: 2,
              //       ),
              //     ),
              //   ),
              //   style: TextStyle(color: Colors.black, fontSize: 18),
              // ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
