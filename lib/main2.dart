import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:confetti/confetti.dart';
import 'dart:developer';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gfg Lunch Wheel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class Lunch {
  final String meal;
  var img;

  Lunch({required this.meal, this.img});

  factory Lunch.fromJson(Map<String, dynamic> json) {
    return Lunch(meal: json['strMeal'], img: json['strMealThumb']);
  }
}

class _ExamplePageState extends State<ExamplePage> {
  StreamController<int> selected = StreamController<int>();
  late ConfettiController _centerController;

  String url = "https://www.themealdb.com/api/json/v1/1/filter.php?a=Indian";
  List<Lunch> _ideas = [];

  Future<void> _getLunchIdeas() async {
    http.Response response;

    Uri uri = Uri.parse(url);
    response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData['meals'] != null) {
        List<dynamic> meals = jsonData['meals'];
        setState(() {
          _ideas = meals.map((json) => Lunch.fromJson(json)).toList();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getLunchIdeas();
    _centerController =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  void dispose() {
    selected.close();
    _centerController.dispose();
    super.dispose();
  }

  var selectedIdea = "";
  late var selectedImg;
  void setValue(value) {
    selectedIdea = _ideas[value].meal.toString();
    selectedImg = _ideas[value].img;
  }

  @override
  Widget build(BuildContext context) {
    var flag = false;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Gfg Lunch Wheel'),
        ),
        body: _ideas.length > 2
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selected.add(
                        Fortune.randomInt(0, _ideas.length),
                      );
                    });
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: FortuneWheel(
                          selected: selected.stream,
                          physics: NoPanPhysics(),
                          indicators: <FortuneIndicator>[
                            FortuneIndicator(
                              alignment: Alignment
                                  .bottomCenter, // <-- changing the position of the indicator
                              child: TriangleIndicator(
                                color: Colors
                                    .green, // <-- changing the color of the indicator
                                width:
                                    20.0, // <-- changing the width of the indicator
                                height:
                                    20.0, // <-- changing the height of the indicator
                                elevation:
                                    0, // <-- changing the elevation of the indicator
                              ),
                            ),
                          ],
                          items: [
                            for (var it in _ideas)
                              FortuneItem(
                                  child: Text(it.meal),
                                  style: FortuneItemStyle(
                                      color: Colors.red,
                                      borderColor: Colors.black,
                                      borderWidth: 5)),
                          ],
                          onAnimationEnd: () {
                            _centerController.play();

                            //   showDialog(
                            //       barrierDismissible: true,
                            //       context: context,
                            //       builder: (BuildContext context) {
                            //         return Center(
                            //           child: AlertDialog(
                            //             scrollable: true,
                            //             title: Text("Hurray! today's meal is????"),
                            //             content: Column(
                            //               children: [
                            //                 ConfettiWidget(
                            //                     confettiController:
                            //                     _centerController,
                            //                     blastDirection: pi / 2,
                            //                     maxBlastForce: 5,
                            //                     minBlastForce: 1,
                            //                     emissionFrequency: 0.03,
                            //                     numberOfParticles: 10,
                            //                     gravity: 0),
                            //                 SizedBox(height: 10),
                            //                 Text(
                            //                   selectedIdea,
                            //                   style: TextStyle(fontSize: 22),
                            //                 ),
                            //                 SizedBox(height: 20),
                            //                 Image.network(selectedImg),
                            //               ],
                            //             ),
                            //           ),
                            //         );
                            //       });
                          },
                          onFocusItemChanged: (value) {
                            if (flag == true) {
                              setValue(value);
                            } else {
                              flag = true;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(color: Colors.green),
              ));
  }
}
