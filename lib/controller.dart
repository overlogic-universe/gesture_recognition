import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'main.dart';

class CamController extends GetxController with WidgetsBindingObserver {
  late CameraController cameraController;
  late void cameraValue;
  late FlashMode mode;
  RxBool isFlashOn = false.obs;
  RxBool isFrontCamera = true.obs;
  RxBool isTakingPicture = false.obs;
  RxInt cameraPositioned = 1.obs;
  int imageCount = 0;
  bool isDetecting = false;
  String who = "";
  String percentage = "";

  @override
  void onInit() async {
    WidgetsBinding.instance.addObserver(this);
    mode = FlashMode.off;
    cameraController = CameraController(cameras[1], ResolutionPreset.max);
    await _initCameraController();
    await _initTensorFlow();
    update();
    super.onInit();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    Tflite.close();
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
          await _initCameraController();
          await cameraController.resumePreview();
          isFlashOn.value = false;
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    update();
  }

  Future<void> _initCameraController() async {
    await cameraController.initialize();
    await _imageStream();
  }

  Future<void> _imageStream() async {
    if (cameraController.value.isInitialized) {
      cameraController.startImageStream((image) async {
        if (!isDetecting) {
          isDetecting = true;
          await _objectRecognition(image);
          isDetecting = false;
        }
      });
    }
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
      await _initCameraController();
    } catch (e) {
      debugPrint(e.toString());
    }
    Get.forceAppUpdate();
  }

  Future<void> _initTensorFlow() async {
    await Tflite.loadModel(
        model: 'assets/models/bisindo/model.tflite',
        labels: 'assets/models/bisindo/labels.txt',
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false);
  }

  Future<void> _objectRecognition(CameraImage cameraImage) async {
    var recognitions = await Tflite.runModelOnFrame(
        bytesList: cameraImage.planes.map((plane) {
          return plane.bytes;
        }).toList(), // required
        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        imageMean: 127.5, // defaults to 127.5
        imageStd: 127.5, // defaults to 127.5
        rotation: 90, // defaults to 90, Android only
        numResults: 2, // defaults to 5
        threshold: 0.1, // defaults to 0.1
        asynch: true // defaults to true
        );

    if (recognitions != null) {
      if (recognitions.isNotEmpty) {
        who = recognitions[0]["label"];
        double confidence = recognitions[0]["confidence"];
        percentage = '${(confidence * 100).toStringAsFixed(0)}%';
        update();
      } else {
        who = 'Unexpectd error';
        percentage = '';
        update();
      }
    }
  }
}
