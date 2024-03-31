import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CamController());
    return GetBuilder<CamController>(
        builder: (_) => !controller.cameraController.value.isInitialized
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : Scaffold(body: CameraPreview(controller.cameraController)));
  }
}
