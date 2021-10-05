// ignore_for_file: unnecessary_null_comparison
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class DrawingArea {
  Offset point;
  Paint areaPaint;

  DrawingArea({required this.point, required this.areaPaint});
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DrawingArea> points = [];
  late Color selectedColor;
  late double strokeWidth;
  String imagePath = "";
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    selectedColor = Colors.black;
    strokeWidth = 2.0;
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    void selectColor() {
      showDialog(
        builder: (context) => AlertDialog(
          title: const Text('Color Chooser'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                setState(() {
                  selectedColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close"))
          ],
        ),
        context: context,
      );
    }

    void _imagepicker() async {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        File? croppedFile = await ImageCropper.cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.green[700],
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: Colors.green[700],
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          iosUiSettings: const IOSUiSettings(
            minimumAspectRatio: 1.0,
          ),
        );
        if (croppedFile != null) {
          setState(() {
            imagePath = croppedFile.path;
          });
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Painter",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Color.fromRGBO(24, 49, 255, 0.13),
                    Color.fromRGBO(40, 14, 166, 0.67),
                    Color.fromRGBO(183, 236, 255, 0.55),
                  ])),
            ),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: width * 0.80,
                      height: height * 0.80,
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 5.0,
                              spreadRadius: 1.0,
                            )
                          ]),
                      child: GestureDetector(
                        onPanDown: (details) {
                          setState(() {
                            points.add(DrawingArea(
                                point: details.localPosition,
                                areaPaint: Paint()
                                  ..strokeCap = StrokeCap.round
                                  ..isAntiAlias = true
                                  ..color = selectedColor
                                  ..strokeWidth = strokeWidth));
                          });
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            points.add(DrawingArea(
                                point: details.localPosition,
                                areaPaint: Paint()
                                  ..strokeCap = StrokeCap.round
                                  ..isAntiAlias = true
                                  ..color = selectedColor
                                  ..strokeWidth = strokeWidth));
                          });
                        },
                        onPanEnd: (details) {
                          // ignore: unnecessary_this
                          this.setState(() {
                            points.isEmpty;
                          });
                        },
                        child: SizedBox.expand(
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20.0)),
                            child: CustomPaint(
                              painter: MyCustomPainter(points: points),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: width * 0.80,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    child: Column(
                      children: [
                        Row(
                          children: <Widget>[
                            IconButton(
                                icon: Icon(
                                  Icons.color_lens,
                                  color: selectedColor,
                                ),
                                onPressed: () {
                                  selectColor();
                                }),
                            Expanded(
                              child: Slider(
                                min: 1.0,
                                max: 5.0,
                                label: "Stroke $strokeWidth",
                                activeColor: selectedColor,
                                value: strokeWidth,
                                onChanged: (double value) {
                                  setState(() {
                                    strokeWidth = value;
                                  });
                                },
                              ),
                            ),
                            IconButton(
                                icon: Icon(
                                  Icons.layers_clear,
                                  color: selectedColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    points.clear();
                                  });
                                }),
                          ],
                        ),
                        Row(
                          children: [
                            //Image Icon in
                            IconButton(
                                icon: Icon(
                                  Icons.image,
                                  color: selectedColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _imagepicker();
                                  });
                                }),
                            // Draw Textfield in Drawing Area
                            IconButton(
                                icon: Icon(
                                  Icons.text_fields,
                                  color: selectedColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    //_gettextfield();
                                  });
                                }),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // // TextField _gettextfield() {
  // //   return TextField(
  // //     keyboardType: TextInputType.multiline,
  // //     textAlign:  TextAlign.center,
  // //     maxLines: 10,
  // //      style: TextStyle(
  // //        wordSpacing: 5,
  // //        height: 2,
  // //        color: Colors.black,
  // //        fontWeight: FontWeight.bold,
  // //        fontSize: 15,
  // //        background: Paint()
  // //        ..color = Colors.black
  // //        ..style = PaintingStyle.stroke
  // //        ..strokeWidth = 35
  // //        ..strokeJoin = StrokeJoin.round

  // //      ),
  // //   );
  // }
}

class MyCustomPainter extends CustomPainter {
  List<DrawingArea> points;

  MyCustomPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    for (int x = 0; x < points.length - 1; x++) {
      if (points[x] != null && points[x + 1] != null) {
        canvas.drawLine(
            points[x].point, points[x + 1].point, points[x].areaPaint);
      } else {
        if (points[x] != null && points[x + 1] == null) {
          canvas.drawPoints(
              PointMode.points, [points[x].point], points[x].areaPaint);
        }
      }
    }

    // final textStyle = TextStyle(
    //   color: Colors.black,
    //   fontSize: 30,
    // );
    // final textSpan = TextSpan(
    //   text: 'SALMAN HABIB',
    //   style: textStyle,
    // );
    // final textPainter = TextPainter(
    //   text: textSpan,
    //   textDirection: TextDirection.ltr,
    // );
    // textPainter.layout(
    //   minWidth: 0,
    //   maxWidth: size.width,
    // );
    // final xCenter = (size.width - textPainter.width) / 2;
    // final yCenter = (size.height - textPainter.height) / 2;
    // final offset = Offset(xCenter, yCenter);
    // textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(MyCustomPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
