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
          : _buildCamera(controller),
    );
  }

  Scaffold _buildCamera(CamController controller) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            CameraPreview(controller.cameraController),
            _buildFlipCameaButton(controller)
          ],
        ),
      ),
    );
  }

  Positioned _buildFlipCameaButton(CamController controller) {
    return Positioned(
      top: 20,
      right: 20,
      child: GestureDetector(
        onTap: () => controller.swicthCamera(),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.black.withOpacity(0.3)),
          child: const Icon(Icons.flip_camera_ios_rounded,
              color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
