import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:spinner/config/constants.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spinner/pages/add_wheel.dart';
import 'package:spinner/wheel/flutter_fortune_wheel.dart';

class HomeScreen extends StatefulWidget {
  // final Map wheel;

  const HomeScreen({
    super.key,
    /*required this.wheel*/
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState(/*wheel: this.wheel*/);
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AudioPlayer bgm = AudioPlayer();
  late AudioPlayer decision = AudioPlayer();
  late bool speaker = true;
  StreamController<int> controller = StreamController<int>();
  bool isAnimating = false;
  String winner = "";
  int winner_pos = 1;
  late Map<dynamic, dynamic> wheel = {};
  final Future<SharedPreferences> pref = SharedPreferences.getInstance();
  late String token;
  late int lastWheelId;
  late int spinTime = 9;
  late String winnerName = "";
  late bool removeOnceChosen = true;
  late AnimationController _controller;
  late List originalItems = [];
  late bool showReset = false;
  late bool showAgain = false;
  late bool showSet = false;
  late bool loading = true;

  _HomeScreenState();

  @override
  void initState() {
    bgm = AudioPlayer();
    bgm.setReleaseMode(ReleaseMode.loop);
    bgm.setSourceAsset('sounds/bgm_1.mp3');

    decision = AudioPlayer();
    decision.setSourceAsset('sounds/se_sfx1_cymbal.mp3');
    decision.setReleaseMode(ReleaseMode.release);

    speaker = true;

    super.initState();
    _controller =
        AnimationController(duration: Duration(microseconds: 200), vsync: this);
    winner = "";
    winner_pos = 1;
    pref.then((pref) async {
      token = pref.getString('_token') ?? "";
      speaker = pref.getBool('speaker') ?? true;
      if (token == "") {
        initUser();

        setState(() {
          loading = false;
          wheel = {};
        });

      } else {
        lastWheelId = pref.getInt('lastWheelId') ?? 0;
        if (lastWheelId != 0) {
          _getWheel(token, lastWheelId);
        } else {
          setState(() {
            loading = false;
          });
        }
      }
      await bgm.setVolume(speaker ? 1 : 0);
      await decision.setVolume(speaker ? 1 : 0);
      spinTime = pref.getInt('spinTime') ?? 9;
      removeOnceChosen = pref.getBool('removeOnceChosen') ?? true;
    });
    loading = true;
  }

  Color _getColor(String hexColorCode) {
    return Color.fromRGBO(
        int.parse(hexColorCode.substring(1, 3), radix: 16),
        int.parse(hexColorCode.substring(3, 5), radix: 16),
        int.parse(hexColorCode.substring(5, 7), radix: 16),
        1);
  }

  void _getWheel(String token, int ID) async {
    Uri uri = Uri.parse(
        "${localURL}?token=$token&resource=wheels&argument=get&id=$ID");
    http.Response response = await http.get(uri);
    Map result = json.decode(response.body);
    if (result['status'] == 1) {
      setState(() {
        winnerName = result['data']['winner'] ?? "";
        wheel = result['data'];
        originalItems = jsonDecode(jsonEncode(wheel['items']));
      });
    }
    setState(() {
      loading = false;
    });
  }

  Future<int> _getWinnerPos() async {
    Uri uri = Uri.parse(
        "${localURL}?token=$token&resource=wheels&argument=winner&id=$lastWheelId");
    http.Response response = await http.get(uri);
    Map result = json.decode(response.body);
    if (result['status'] == 1 && result['data'] != null) {
      var index = wheel['items'].indexWhere((item) {
        return item['name'] == result['data'];
      });
      if (index == -1) {
        return Random().nextInt(wheel['items'].length);
      } else {
        if (removeOnceChosen && wheel['items'].length > 1) {
          List all = [];
          for (int i = 0; i < wheel['items'].length; i++) {
            if (index != i) {
              all.add(i);
            }
          }
          all.shuffle();
          return all[0];
        } else {
          return index;
        }
      }
    } else {
      return Random().nextInt(wheel['items'].length);
    }
  }

  void initUser() async {
    Uri uri = Uri.parse("$localURL?resource=app_user&argument=register");
    http.Response response = await http.get(uri);
    Map result = json.decode(response.body);
    print('===user===');
    print(result);
    if (result['status'] == 1) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('_token', result['data']['token']);
      pref.setInt('lastWheelId', 0);
    }
  }

  void _spin() {
    if (!isAnimating) {
      setState(() {
        winner = "";
        _controller.forward();
        Future.delayed(Duration(milliseconds: showSet ? 0 : 200), () {
          _controller.reverse();
        });
        _getWinnerPos().then((winner_p) {
          setState(() {
            winner_pos = winner_p;
            print('winner pos:$winner_pos');
            controller.add(winner_pos);
          });
        });
      });
    }
  }

  void _reset() {
    setState(() {
      wheel['items'] = jsonDecode(jsonEncode(originalItems));
      showReset = false;
      winner = "";
    });
  }

  void _manageButtons() {
    if (removeOnceChosen) {
      setState(() {
        if (wheel['items'].length > 2) {
          showAgain = true;
          showSet = true;
          showReset = false;
        }
      });
    }
  }

  void _setItems() {
    setState(() {
      showSet = false;
      showAgain = false;
      showReset = true;
      winner = "";
      if (wheel['items'].length > 2) {
        wheel['items'].removeAt(winner_pos);
      }
    });
  }

  void _show_reset_alert(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            // title: Text(
            //   "Confirmation",
            //   style: TextStyle(fontSize: 20),
            // ),
            content: Text(
              "Aue you sure you want to reset this wheel?",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 20, color: Color(0xFF1cafff)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: Text(
                  'Yes',
                  style: TextStyle(fontSize: 20, color: Color(0xFFfb6e74)),
                ),
                onPressed: () {
                  _reset();
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor:
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Color(0xFF1d1f2e)
                : Color(0xFF1d1f2e),
        // : Color(0xFFFFFFFF),
        padding: EdgeInsetsDirectional.only(top: 10, start: 10, end: 10),
        leading: wheel.isNotEmpty
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.pushNamed(context, 'settings');
                },
                // child: Icon(
                //   CupertinoIcons.,
                //   color: Color(0xFF1cafff),
                //   size: 46,
                // ),
                child: Transform.rotate(
                  angle: 13,
                  child: SvgPicture.asset(
                    "svg/settings.svg",
                    height: 40,
                    color: Color(0xFF1cafff),
                  ),
                ),
              )
            : SizedBox(),
        middle: wheel.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CupertinoTextField(
                  suffix: Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: Color(0xFF1cafff),
                    size: 30,
                  ),
                  readOnly: true,
                  controller: TextEditingController(text: wheel['name']),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                  placeholderStyle: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFFc3c4c4)),
                  padding: EdgeInsets.only(top: 10, bottom: 10, left: 30),
                  textAlign: TextAlign.center,
                  decoration: BoxDecoration(
                      color: Color(0xFF3b3f4b),
                      border: Border.all(color: Color(0xFF4d5261), width: 2),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      )),
                  onTap: () async {
                    Navigator.pushNamed(context, 'wheels');
                  },
                ),
              )
            : SizedBox(),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            SharedPreferences.getInstance().then((pref) {
              pref.setInt('selectedWheelID', 0);
            });
            Navigator.pushNamed(context, 'add-new-wheel');
          },
          child: Icon(
            CupertinoIcons.add_circled,
            color: Color(0xFF1cafff),
            size: 46,
          ),
        ),
        automaticBackgroundVisibility: false,
      ),
      // backgroundColor: Color(0xFF1d1f2e),
      child: wheel.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    height: 43,
                  ),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        height: MediaQuery.sizeOf(context).width - 60,
                        width: MediaQuery.sizeOf(context).width - 60,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              // color: Colors.blue,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(
                                    (MediaQuery.sizeOf(context).width - 60) /
                                        2)),
                                color: Color(0xff30344c),
                              ),
                              child: FortuneWheel(
                                duration: Duration(seconds: spinTime),
                                rotationCount: 10,
                                curve: Curves.decelerate,
                                animateFirst: false,
                                physics: NoPanPhysics(),
                                selected: controller.stream,
                                onAnimationStart: () async {
                                  await decision.stop();
                                  await bgm
                                      .play(AssetSource('sounds/bgm_1.mp3'));
                                  setState(() {
                                    isAnimating = true;
                                  });
                                },
                                onAnimationEnd: () async {
                                  await bgm.stop();
                                  await decision.play(
                                      AssetSource('sounds/se_sfx1_cymbal.mp3'));
                                  setState(() {
                                    isAnimating = false;
                                    winner = wheel['items'][winner_pos]['name'];
                                    _manageButtons();
                                  });
                                },
                                hapticImpact: HapticImpact.none,
                                indicators: [
                                  FortuneIndicator(
                                    child: Transform.translate(
                                      offset: Offset(0, -20),
                                      child: Transform.rotate(
                                        angle: pi,
                                        child: CustomPaint(
                                          size: Size(60, 50),
                                          painter: RoundedTrianglePainter(),
                                        ),
                                      ),
                                    ),
                                    alignment: Alignment.topCenter,
                                  ),
                                  FortuneIndicator(
                                    child: Transform.translate(
                                      offset: Offset(0, -110),
                                      child: Text(
                                        winner,
                                        style: TextStyle(
                                            fontSize: 35,
                                            fontFamily: 'Helvetica-neu-bold',
                                            decoration: TextDecoration.none,
                                            color: Colors.white),
                                      ),
                                    ),
                                    alignment: Alignment.topCenter,
                                  )
                                ],
                                items: [
                                  for (var item in wheel['items'])
                                    FortuneItem(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                            child: Text(
                                              item['name'],
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                      style: FortuneItemStyle(
                                          color: _getColor(item['color']),
                                          borderColor: Color(0xff30344c),
                                          borderWidth: 1.5,
                                          textAlign: TextAlign.center),
                                    )
                                ],
                              ),
                            ),
                            Positioned(
                              child: GestureDetector(
                                onTap: () {
                                  if (showSet) {
                                    _setItems();
                                  } else {
                                    _spin();
                                  }
                                },
                                child: ScaleTransition(
                                  scale: Tween<double>(
                                    begin: 1.0,
                                    end: 0.85,
                                  ).animate(_controller),
                                  child: ElevatedButton(
                                    onPressed: null,
                                    style: ElevatedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(24),
                                      // Adjust size
                                      disabledBackgroundColor:
                                          Color(0xff30344c),
                                      // Button color
                                      disabledForegroundColor: Colors.blue,
                                      // Text/icon color
                                      elevation: 2, // Shadow effect
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Text(
                                        showSet ? 'SET' : 'START',
                                        style: TextStyle(letterSpacing: 3),
                                      ),
                                    ), // Add an icon
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      showAgain
                          ? CupertinoButton(
                              // color: Colors.red,
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              child: Text(
                                '再轉一次',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1cafff)),
                              ),
                              onPressed: () {
                                _spin();
                                Future.delayed(Duration(milliseconds: 100), () {
                                  setState(() {
                                    showSet = false;
                                  });
                                });
                              },
                            )
                          : SizedBox(
                              height: 43,
                            ),
                      showReset
                          ? CupertinoButton(
                              // color: Colors.red,
                              padding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              child: Text(
                                '重設',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1cafff)),
                              ),
                              onPressed: () {
                                _show_reset_alert(context);
                              },
                            )
                          : SizedBox(
                              height: 43,
                            ),
                    ],
                  ),
                  Row(
                    children: [
                      // CupertinoButton(
                      //   child: Icon(
                      //     speaker ? Icons.volume_up : Icons.volume_off,
                      //     size: 50,
                      //     color: Color(0xFF1cafff),
                      //   ),
                      //   onPressed: () async {
                      //     await bgm.setVolume(speaker ? 0 : 1);
                      //     await decision.setVolume(speaker ? 0 : 1);
                      //     SharedPreferences pref =
                      //         await SharedPreferences.getInstance();
                      //     setState(() {
                      //       speaker = !speaker;
                      //       pref.setBool('speaker', speaker);
                      //     });
                      //   },
                      // ),
                      Expanded(child: Text("")),
                      ElevatedButton(
                        onPressed: () async {
                          SharedPreferences pref =
                              await SharedPreferences.getInstance();
                          pref.setInt('selectedWheelID', lastWheelId);
                          Navigator.push(context,
                              CupertinoPageRoute(builder: (context) {
                            return AddWheelScreen(
                              wheelTitle: wheel['name'],
                              slices: wheel['items'],
                            );
                          }));
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(10),
                          backgroundColor: Color(0xFF1cafff),
                          elevation: 2, // Shadow effect
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 40,
                            color: Color(0xFFFFFFFF),
                          ),
                        ), // Add an icon
                      )
                    ],
                  )
                ],
              ),
            )
          : Container(
              height: MediaQuery.sizeOf(context).height - 40,
              margin: EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 12),
                child: loading
                    ? SizedBox()
                    : Stack(
                        children: [
                          Text(
                            "點選右上角的「+」按鈕來建立新轉盤!",
                            style: TextStyle(
                                fontSize: 23,
                                color: Colors.white,
                                fontFamily: 'Helvetica-neu-bold',
                                decoration: TextDecoration.none),
                            textAlign: TextAlign.center,
                          ),
                          Column(
                            children: [
                              Expanded(
                                child: Center(
                                  child: SizedBox(
                                    height:
                                        MediaQuery.sizeOf(context).width - 60,
                                    width:
                                        MediaQuery.sizeOf(context).width - 60,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          // color: Colors.blue,
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      (MediaQuery.sizeOf(
                                                                      context)
                                                                  .width -
                                                              60) /
                                                          2)),
                                              color: Color(0xff292c3b),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Color(0xFF181823),
                                                    blurRadius: 5.0,
                                                    blurStyle: BlurStyle.outer)
                                              ]),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                child: FortuneWheel(
                                                  duration:
                                                      Duration(seconds: 5),
                                                  rotationCount: 10,
                                                  curve: Curves.decelerate,
                                                  animateFirst: false,
                                                  physics: NoPanPhysics(),
                                                  onAnimationStart: () =>
                                                      isAnimating = true,
                                                  onAnimationEnd: () =>
                                                      isAnimating = false,
                                                  hapticImpact:
                                                      HapticImpact.none,
                                                  indicators: [
                                                    FortuneIndicator(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: Color(
                                                                0xFF434655),
                                                            borderRadius: BorderRadius.all(
                                                                Radius.circular(
                                                                    MediaQuery.sizeOf(context)
                                                                            .width -
                                                                        60))),
                                                      ),
                                                    ),
                                                    FortuneIndicator(
                                                      child:
                                                          Transform.translate(
                                                        offset: Offset(0, -20),
                                                        child: Transform.rotate(
                                                          angle: pi,
                                                          child: CustomPaint(
                                                            size: Size(60, 50),
                                                            painter:
                                                                RoundedTrianglePainter(),
                                                          ),
                                                        ),
                                                      ),
                                                      alignment:
                                                          Alignment.topCenter,
                                                    ),
                                                    FortuneIndicator(
                                                        child: ElevatedButton(
                                                      onPressed: () {},
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape:
                                                            const CircleBorder(),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        // Adjust size
                                                        backgroundColor:
                                                            Color(0xff3b3f4b),
                                                        // Button color
                                                        foregroundColor:
                                                            Color(0xFF8dd5fc),
                                                        // Text/icon color
                                                        elevation:
                                                            0, // Shadow effect
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        child: const Text(
                                                          'START',
                                                          style: TextStyle(
                                                              letterSpacing: 3),
                                                        ),
                                                      ), // Add an icon
                                                    ))
                                                  ],
                                                  items: [
                                                    for (var item in [1, 2])
                                                      FortuneItem(
                                                          child: Text(''),
                                                          style: FortuneItemStyle(
                                                              color: Color(
                                                                  0xFF434655),
                                                              borderColor: Color(
                                                                  0xFF434655)))
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
    );
  }
}

class RoundedTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw rounded triangle
    var radius = 3.0;
    Path triangle = Path();
    triangle.moveTo(0.0 + radius, size.height - radius * 1.4);
    triangle.arcToPoint(Offset(0.0 + (radius * 2), size.height),
        radius: Radius.circular(radius), clockwise: false);
    triangle.lineTo(size.width - radius * 2, size.height);
    triangle.arcToPoint(Offset(size.width - radius, size.height - radius * 1.4),
        radius: Radius.circular(radius), clockwise: false);
    triangle.lineTo(size.width / 2 + radius, 0.0 + radius * 2);
    triangle.arcToPoint(Offset(size.width / 2 - radius, 0.0 + radius * 2),
        radius: Radius.circular(radius * 1.1), clockwise: false);
    triangle.close();

    canvas.drawPath(triangle, fillPaint);
    canvas.drawPath(triangle, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
