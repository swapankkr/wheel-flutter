import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spinner/config/constants.dart';
import 'package:spinner/pages/add_wheel.dart';
import 'package:spinner/pages/home.dart';

class WheelsScreen extends StatefulWidget {
  WheelsScreen({super.key});

  @override
  _WheelsScreenState createState() => _WheelsScreenState();
}

class _WheelsScreenState extends State<WheelsScreen> {
  late List wheels;
  late String token;
  Future<SharedPreferences> pref = SharedPreferences.getInstance();

  @override
  void initState() {
    wheels = [];
    super.initState();
    pref.then((pref) {
      token = pref.getString('_token') ?? "";
      _getWheels(token, false);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _getWheels(token, refresh) async {
    Uri uri = Uri.parse("${localURL}?token=$token&resource=wheels&argument=");
    http.Response response = await http.get(uri);
    Map result = json.decode(response.body);
    if (result['status'] == 1) {
      setState(() {
        wheels = result['data'];
        pref.then((pref) {
          if (wheels.isEmpty) {
            pref.setInt('lastWheelId', 0);
            Navigator.pushReplacement(context,
                CupertinoPageRoute(builder: (BuildContext context) {
              return HomeScreen(/*wheel: getWheel()*/);
            }));
          }else{
            if(refresh){
              pref.setInt('lastWheelId', int.parse(wheels[0]['id']));
            }
          }
        });
      });
    }
  }

  void _deleteWheel(token, id) async {
    Uri uri = Uri.parse(
        "${localURL}?token=$token&resource=wheels&argument=delete&id=$id");
    http.Response response = await http.get(uri);
    Map result = json.decode(response.body);
    if (result['status'] == 1) {
      pref.then((pref) {
        int lastActiveWheelID = pref.getInt('lastWheelId') ?? 0;
        _getWheels(token, lastActiveWheelID == int.parse(id));
      });
    }
  }

  Color _getColor(String hexColorCode) {
    return Color.fromRGBO(
        int.parse(hexColorCode.substring(1, 3), radix: 16),
        int.parse(hexColorCode.substring(3, 5), radix: 16),
        int.parse(hexColorCode.substring(5, 7), radix: 16),
        1);
  }

  void _show_confirm_to_remove_alert(BuildContext context, id) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              "Confirmation",
              style: TextStyle(fontSize: 20),
            ),
            content: Text(
              "Aue you sure to remove this wheel?",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text(
                  'NO',
                  style: TextStyle(fontSize: 20, color: Color(0xFF1cafff)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: Text(
                  'YES',
                  style: TextStyle(fontSize: 20, color: Color(0xFFfb6e74)),
                ),
                onPressed: () {
                  _deleteWheel(token, id);
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
                : Color(0xFFFFFFFF),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.pushReplacement(context,
                CupertinoPageRoute(builder: (BuildContext context) {
                  return HomeScreen(/*wheel: getWheel()*/);
                }));
          },
          child: Icon(
            CupertinoIcons.multiply,
            color: Color(0xFF1cafff),
            size: 46,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            SharedPreferences pref = await SharedPreferences.getInstance();
            pref.setInt('selectedWheelID', 0);
            Navigator.pushNamed(context, 'add-new-wheel');
          },
          child: Icon(
            CupertinoIcons.add_circled,
            color: Color(0xFF1cafff),
            size: 46,
          ),
        ),
        border: Border(bottom: BorderSide(color: Color(0xFF4d5261), width: 1)),
        automaticBackgroundVisibility: false,
        padding:
            EdgeInsetsDirectional.only(bottom: 10, start: 5, end: 10, top: 5),
      ),
      backgroundColor: Color(0xFF1d1f2e),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: ListView(
          children: [
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 10)),
            Column(
              spacing: 20,
              children: wheels.map((wheel) {
                return Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          SharedPreferences pref =
                              await SharedPreferences.getInstance();
                          pref.setInt('lastWheelId', int.parse(wheel['id']));
                          print(pref.getInt('lastWheelId'));
                          Navigator.pushReplacement(context, CupertinoPageRoute(
                              builder: (BuildContext context) {
                            return HomeScreen(/*wheel: getWheel()*/);
                          }));
                        },
                        child: Card(
                          color: Color(0xFF292c3b),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Row(
                              spacing: 10,
                              children: [
                                SizedBox(
                                  width: 130,
                                  height: 130,
                                  child: Container(
                                    padding: EdgeInsets.all(2.5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              (MediaQuery.sizeOf(context)
                                                          .width -
                                                      60) /
                                                  2)),
                                      color: Color(0xff30344c),
                                    ),
                                    child: FortuneWheel(
                                      animateFirst: false,
                                      physics: NoPanPhysics(),
                                      indicators: [
                                        FortuneIndicator(
                                          child: Transform.translate(
                                            offset: Offset(0, -11),
                                            child: Transform.rotate(
                                              angle: pi,
                                              child: CustomPaint(
                                                size: Size(28, 25),
                                                painter:
                                                    RoundedTrianglePainterThin(),
                                              ),
                                            ),
                                          ),
                                          alignment: Alignment.topCenter,
                                        ),
                                        FortuneIndicator(
                                          child: ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              shape: const CircleBorder(),
                                              padding: const EdgeInsets.all(0),
                                              // Adjust size
                                              backgroundColor:
                                                  Color(0xff30344c),
                                              // Button color
                                              foregroundColor: Colors.blue,
                                              // Text/icon color
                                              elevation: 2, // Shadow effect
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(17.5),
                                              child: const Text(
                                                'START',
                                                style: TextStyle(
                                                    letterSpacing: 2,
                                                    fontSize: 7),
                                              ),
                                            ), // Add an icon
                                          ),
                                        )
                                      ],
                                      items: [
                                        for (var item in wheel['items'])
                                          FortuneItem(
                                            child: Text(
                                              item['name'],
                                              style: TextStyle(fontSize: 8),
                                            ),
                                            style: FortuneItemStyle(
                                              color: _getColor(item['color']),
                                              borderWidth: 0.75,
                                              borderColor: Color(0xff30344c),
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Text(
                                  wheel['name'],
                                  style: TextStyle(fontSize: 18),
                                )),
                                Column(
                                  spacing: 20,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        SharedPreferences pref =
                                            await SharedPreferences
                                                .getInstance();
                                        pref.setInt('selectedWheelID',
                                            int.parse(wheel['id']));
                                        Navigator.push(context,
                                            CupertinoPageRoute(
                                                builder: (context) {
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
                                          size: 30,
                                          color: Color(0xFFFFFFFF),
                                        ),
                                      ), // Add an icon
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _show_confirm_to_remove_alert(
                                            context, wheel['id']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(10),
                                        backgroundColor: Color(0xFFfc4d5a),
                                        elevation: 2, // Shadow effect
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: const Icon(
                                          CupertinoIcons.delete,
                                          size: 30,
                                          color: Color(0xFFFFFFFF),
                                        ),
                                      ), // Add an icon
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}

class RoundedTrianglePainterThin extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw rounded triangle
    var radius = 2.0;
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
