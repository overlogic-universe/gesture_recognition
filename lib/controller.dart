import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'main.dart';

class CamController extends GetxController with WidgetsBindingObserver {
  late CameraController cameraController;
  late void cameraValue;
  late FlashMode mode;
  RxBool isFlashOn = false.obs;
  RxBool isFrontCamera = true.obs;
  RxBool isTakingPicture = false.obs;
  RxInt cameraPositioned = 0.obs;

  @override
  void onInit() async {
    WidgetsBinding.instance.addObserver(this);
    mode = FlashMode.off;
    cameraController = CameraController(cameras[1], ResolutionPreset.max);
    cameraValue = await cameraController.initialize();
    update();
    super.onInit();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    update();
    super.onClose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      try {
        if (cameraController.value.isInitialized) {
          mode = FlashMode.off;
          await cameraController.setFlashMode(mode);
          await cameraController.pausePreview();
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    } else if (state == AppLifecycleState.resumed) {
      try {
        if (cameraController.value.isInitialized) {
          cameraController = CameraController(
              cameras[cameraPositioned.value], ResolutionPreset.max);
          cameraValue = await cameraController.initialize();
          await cameraController.resumePreview();
          isFlashOn.value = false;
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    update();
  }

  Future<void> outOfCamera() async {
    try {
      isFlashOn.value = false;
      await cameraController.setFlashMode(FlashMode.off);
    } catch (e) {
      debugPrint(e.toString());
    }

    Get.back();
    update();
  }

  Future<void> onSetFlashModeButtonPressed() async {
    isFlashOn.toggle();
    if (isFlashOn.value) {
      mode = FlashMode.torch;
    } else {
      mode = FlashMode.off;
    }
    try {
      await cameraController.setFlashMode(mode);
    } catch (e) {
      debugPrint(e.toString());
    }
    update();
  }

  Future<void> swicthCamera() async {
    isFrontCamera.toggle();
    isFlashOn.value = false;
    if (isFrontCamera.value) {
      cameraPositioned.value = 1;
    } else {
      cameraPositioned.value = 0;
    }
    try {
      cameraController = CameraController(
          cameras[cameraPositioned.value], ResolutionPreset.max);
      cameraValue = await cameraController.initialize();
    } catch (e) {
      debugPrint(e.toString());
    }
    Get.forceAppUpdate();
  }
}
