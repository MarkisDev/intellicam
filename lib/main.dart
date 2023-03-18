import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Object Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CanineCam(),
    );
  }
}

class CanineCam extends StatefulWidget {
  CanineCam({Key? key}) : super(key: key);

  @override
  _CanineCamState createState() {
    return _CanineCamState();
  }
}

class _CanineCamState extends State<CanineCam> {
  dynamic controller;
  dynamic objectDetector;
  CameraImage? img;

// Function to get the path of the fine-tuned model
  Future<String> _getModel(String assetPath) async {
    if (Platform.isAndroid) {
      return 'flutter_assets/$assetPath';
    }
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  @override
  void initState() {
    super.initState();
    initCamera();
  }

// This function initializes the camera and starts image stream
// We declare controller as dynamic since the controller might return null (when not initialized, async!)
  initCamera() async {
    final modelPath = await _getModel('assets/ml/model.tflite');
    final options = LocalObjectDetectorOptions(
        modelPath: modelPath,
        classifyObjects: true,
        multipleObjects: true,
        mode: DetectionMode.stream);
    objectDetector = ObjectDetector(options: options);

    controller = CameraController(cameras[0], ResolutionPreset.high);
    await controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((image) async {
        img = image;

        InputImage frameImg = getInputImage();
        List<DetectedObject> objects =
            await objectDetector.processImage(frameImg);
        print("detected ${objects}");
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('Camera access denied!');
            break;
          default:
            print('Camera initalization error!');
            break;
        }
      }
    });
  }

// This function will convert the cameraImage to an InputImage so we can use it for processing
  InputImage getInputImage() {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in img!.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(img!.width.toDouble(), img!.height.toDouble());
    final camera = cameras[0];

    final planeData = img!.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation:
          InputImageRotationValue.fromRawValue(camera.sensorOrientation)!,
      inputImageFormat: InputImageFormatValue.fromRawValue(img!.format.raw)!,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    return inputImage;
  }

  @override
  void dispose() {
    controller?.dispose();
    objectDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('CanineCam'),
          centerTitle: true,
        ),
        body: (controller == null)
            ? Container(
                child: Center(
                child: Column(children: [
                  Text('Loading...'),
                  SpinKitRotatingCircle(
                    color: Colors.grey,
                    size: 30.0,
                  )
                ]),
              ))
            : CameraPreview(controller));
  }
}
