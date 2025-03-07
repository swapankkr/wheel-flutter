import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spinner/config/constants.dart';
import 'package:spinner/pages/colorpicker.dart';
import 'package:spinner/pages/home.dart';
import 'package:http/http.dart' as http;

class AddWheelScreen extends StatefulWidget {
  String wheelTitle;
  List slices;

  AddWheelScreen({super.key, required this.wheelTitle, required this.slices});

  @override
  State<AddWheelScreen> createState() =>
      _AddWheelScreenState(wheelTitle, slices);
}

class _AddWheelScreenState extends State<AddWheelScreen> {
  TextEditingController wheelNameController = TextEditingController(text: "");
  static bool editMode = false;
  var slices = [];
  var textEditorControllers = [];
  var weightEditorControllers = [];
  var lastColorIndex = 0;
  static var colors = [
    "#fb6e74",
    "#fbe05d",
    "#8aecb3",
    "#80e2fb",
    "#b48cee",
    "#f784bb",
    "#f9bc51",
    "#52bc7a",
    "#7b9ce9",
    "#b473c3",
    "#f66e78",
    "#faa94e",
    "#87e0a0",
    "#81ebf9",
    "#b087cb",
    "#f95e7d",
    "#f2e45d",
    "#74ce98",
    "#1ee2de",
    "#a680bb",
    "#f5515a",
    "#e8d26c",
    "#61b584",
    "#7bdbd7",
    "#9f70a7",
    "#f47f9c",
    "#e8b951",
    "#8bc53d",
    "#71ccbd",
    "#7b71c8",
    "#df76a1",
    "#f89753",
    "#84b537",
    "#61d0e3",
    "#6b66b6",
    "#de5eb3",
    "#f6a800",
    "#7aa52f",
    "#0daffa",
    "#554ba2",
    "#f343d2",
    "#ee9118",
    "#778e22",
    "#048ce4",
    "#454092",
    "#f240a2",
    "#db7a19",
    "#626e2c",
    "#ffffff",
    '#000000'
  ];
  var saving = 0;
  late String token;
  Future<SharedPreferences> pref = SharedPreferences.getInstance();

  _AddWheelScreenState(wheelTitle, this.slices) {
    wheelNameController.text = wheelTitle;
    this.slices.forEach((item){
      textEditorControllers.add(TextEditingController(text: item['name']));
      weightEditorControllers.add(TextEditingController(text: item['weight']));
    });
  }

  @override
  void initState() {
    super.initState();
    lastColorIndex = colors.indexOf(slices.last['color']);
    editMode = false;
    pref.then((pref){
      token = pref.getString('_token') ?? "";
    });
  }

  void toggleEditMode() {
    setState(() {
      editMode = !editMode;
    });
  }

  String nextColor() {
    lastColorIndex = (lastColorIndex + 1) % colors.length;
    return colors[lastColorIndex];
  }

  Color _getColor(String hexColorCode) {
    return Color.fromRGBO(
        int.parse(hexColorCode.substring(1, 3), radix: 16),
        int.parse(hexColorCode.substring(3, 5), radix: 16),
        int.parse(hexColorCode.substring(5, 7), radix: 16),
        1);
  }

  Map<String, dynamic> getWheel() {
    return {
      'name': wheelNameController.text,
      'items': get_wheel_items(),
    };
  }

  List get_wheel_items() {
    return slices.map((item){
      var index = slices.indexOf(item);
      return {
        'id': item['id'],
        'color': item['color'],
        'name': textEditorControllers[index].text,
        'weight': weightEditorControllers[index].text,
        'order': index+1,
      };
    }).toList();
  }

  Future<int> _saveWheel() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int selectedWheelID = pref.getInt('selectedWheelID') ?? 0;
    var argument = selectedWheelID == 0 ? "store" : "update";
    String data = (jsonEncode(getWheel()));
    Uri uri = Uri.parse("$localURL?token=$token&resource=wheels&argument=$argument&id=$selectedWheelID&data=$data".replaceAll("#", '%23'));
    http.Response response = await http.get(uri);
    Map result = json.decode(response.body);
    if(result['status'] == 1){
      return int.parse(result['data']['id']);
    }else{
      return selectedWheelID;
    }
  }

  void _show_unable_to_remove_alert(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              "Alert",
              style: TextStyle(fontSize: 20),
            ),
            content: Text(
              "Tow or more items must be set.",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text(
                  'OK',
                  style: TextStyle(fontSize: 20, color: Color(0xFF1cafff)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  void _show_confirm_to_remove_alert(BuildContext context, int index) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(
              "Confirmation",
              style: TextStyle(fontSize: 20),
            ),
            content: Text(
              "Aue you sure to remove this item?",
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
                  setState(() {
                    slices.removeAt(index);
                    textEditorControllers.removeAt(index);
                    weightEditorControllers.removeAt(index);
                  });
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  proxyDecorator(child, index, animation) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.secondary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.secondary.withOpacity(0.15);
    final Color draggableItemColor = colorScheme.secondary;
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          color: draggableItemColor,
          shadowColor: draggableItemColor,
          child: child,
        );
      },
      child: child,
    );
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
            Navigator.pop(context);
          },
          child: Icon(
            CupertinoIcons.multiply,
            color: Color(0xFF1cafff),
            size: 46,
          ),
        ),
        trailing: SizedBox(
          width: 80,
          child: CupertinoButton(
            sizeStyle: CupertinoButtonSize.medium,
            onPressed: () {
              toggleEditMode();
            },
            child: Text(
              editMode ? 'Done' : 'Edit',
              style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF1cafff),
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        middle: Padding(
          padding: const EdgeInsets.only(left: 10, right: 0),
          child: CupertinoTextField(
            enabled: !editMode,
            controller: wheelNameController,
            placeholder: 'Enter wheel title',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white),
            placeholderStyle: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFFc3c4c4)),
            padding: EdgeInsets.symmetric(vertical: 10),
            textAlign: TextAlign.center,
            decoration: BoxDecoration(
                color: Color(0xFF3b3f4b),
                border: Border.all(color: Color(0xFF4d5261), width: 2),
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                )),
          ),
        ),
        border: Border(bottom: BorderSide(color: Color(0xFF4d5261), width: 1)),
        automaticBackgroundVisibility: false,
        padding: EdgeInsetsDirectional.only(bottom: 10, start: 5, end: 0),
      ),
      backgroundColor: Color(0xFF1d1f2e),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: SizedBox()),
                    Container(
                      width: 70,
                      padding: EdgeInsets.only(top: 10),
                      child: Text("Weight",
                          style: TextStyle(
                              fontFamily: 'Helvetica-neu-bold',
                              fontSize: 15,
                              color: Colors.white,
                              decoration: TextDecoration.none)),
                    ),
                    SizedBox(
                      width: 54,
                    )
                  ],
                ),
                Expanded(
                    child: ReorderableListView(
                  buildDefaultDragHandles: false,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = slices.removeAt(oldIndex);
                      final nameCtrl = textEditorControllers.removeAt(oldIndex);
                      final weightCtrl = weightEditorControllers.removeAt(oldIndex);
                      slices.insert(newIndex, item);
                      textEditorControllers.insert(newIndex, nameCtrl);
                      weightEditorControllers.insert(newIndex, weightCtrl);
                    });
                  },
                  children: slices.map((slice) {
                    var index = slices.indexOf(slice);
                    return Padding(
                      key: Key(slice['id'].toString()),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 15),
                      child: Row(
                        children: [
                          ReorderableDragStartListener(
                            index: index,
                            enabled: editMode,
                            child: SizedBox(
                              width: editMode ? 40 : 0,
                              child: Icon(
                                Icons.drag_indicator,
                                size: 40,
                                color: CupertinoColors.inactiveGray,
                              ),
                            ),
                          ),
                          GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getColor(slice['color']),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                              ),
                              height: 45,
                              width: 45,
                              child: Text(""),
                            ),
                            onTap: () {
                              if (!editMode) {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (BuildContext context) =>
                                        ColorPickerScreen(
                                      currentColor: slice['color'],
                                      selectedColors: slices
                                          .map((y) => y['color'])
                                          .toList(),
                                      onChange: (color) {
                                        setState(() {
                                          slice['color'] = color;
                                          slices.firstWhere((ele) =>
                                              ele['id'] ==
                                              slice['id'])['color'] = color;
                                        });
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: CupertinoTextField(
                                controller: textEditorControllers[index],
                                enabled: !editMode,
                                placeholder: 'Slice text',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white),
                                placeholderStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFc4c4c4)),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Color(0xFF3b3f4b),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 56,
                            child: CupertinoTextField(
                              enabled: !editMode,
                              maxLength: 3,
                              keyboardType: TextInputType.numberWithOptions(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white),
                              placeholderStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFAAAAAA)),
                              padding: EdgeInsets.all(10),
                              textAlign: TextAlign.center,
                              decoration: BoxDecoration(
                                  color: Color(0xFF3b3f4b),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  border: Border.all(color: Color(0xFF4d5261))),
                              controller: TextEditingController(text: "1"),
                            ),
                          ),
                          Row(
                            children: [
                              CupertinoButton(
                                padding: const EdgeInsets.only(left: 10),
                                onPressed: () {
                                  if (slices.length <= 2) {
                                    _show_unable_to_remove_alert(context);
                                  } else {
                                    setState(() {
                                      _show_confirm_to_remove_alert(
                                          context, index);
                                    });
                                  }
                                },
                                child: Icon(
                                  CupertinoIcons.minus_circle,
                                  color: Color(0xFFC64049),
                                  size: 46,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  }).toList(),
                )),
              ],
            ),
          ),
          !editMode
              ? Column(
                  spacing: 10,
                  children: [
                    CupertinoButton(
                      onPressed: () {
                        setState(() {
                          textEditorControllers.add(TextEditingController(text: ""));
                          weightEditorControllers.add(TextEditingController(text: "1"));
                          slices.add({
                            'id': Random.secure().nextInt(1000),
                            'color': nextColor(),
                            'name': '',
                            'weight': '1',
                            'order': slices.length + 1,
                          });
                        });
                      },
                      color: Color(0xFF1cafff),
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 120),
                      child: Icon(
                        CupertinoIcons.add,
                        color: CupertinoColors.white,
                        size: 50,
                      ),
                    ),
                    CupertinoButton(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 130),
                      color: Color(0xFF1cafff),
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      child: Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 30,
                          color: CupertinoColors.white,
                        ),
                      ),
                      onPressed: () async {
                        var wheelID = await _saveWheel();
                        SharedPreferences pref = await SharedPreferences.getInstance();
                        pref.setInt('lastWheelId', wheelID);
                        Navigator.pushReplacement(context,
                            CupertinoPageRoute(builder: (BuildContext context) {
                          return HomeScreen(/*wheel: getWheel()*/);
                        }));
                      },
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                )
              : SizedBox()
        ],
      ),
    );
  }
}
