import 'package:flutter/material.dart';
import 'package:gesture_recognition/camera_app.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: const CameraApp());
  }
}
