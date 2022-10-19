import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? images;
  List? _output;
  final picker = ImagePicker();

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path.toString(),
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true);
    setState(() {
      _output = output;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModel();
  }

  @override
  void dispose() {
    Tflite.close();
    // TODO: implement dispose
    super.dispose();
  }

  pickImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      images = File(image.path);
    });
    classifyImage(images!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 400,
              width: 400,
            ),
            const SizedBox(
              height: 20,
            ),
            _output != null
                ? Text(_output![0].toString())
                : const Text('Nothing Selected'),
            ElevatedButton(
                onPressed: () async {
                  await pickImage();
                },
                child: Text('Take Photo '))
          ],
        ),
      ),
    );
  }
}
