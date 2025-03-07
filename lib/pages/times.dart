import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spinner/pages/settings.dart';

class TimesScreen extends StatefulWidget {
  TimesScreen({super.key});

  @override
  _TimesScreenState createState() => _TimesScreenState();
}

class _TimesScreenState extends State<TimesScreen> {
  late int spinTime = 9;
  Future<SharedPreferences> pref = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    pref.then((pref) {
      setState(() {
        spinTime = pref.getInt('spinTime') ?? 9;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
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
        middle: Text(
          "旋轉時間",
          style: TextStyle(fontSize: 25, color: Colors.white),
        ),
        border: Border(bottom: BorderSide(color: Color(0xFF4d5261), width: 1)),
        automaticBackgroundVisibility: false,
        padding: EdgeInsetsDirectional.only(bottom: 10, start: 5, end: 0),
      ),
      backgroundColor: Color(0xFF1d1f2e),
      child: Column(
        children: [
          Expanded(
            child: SettingsList(
              darkTheme: SettingsThemeData(
                  settingsListBackground: Color(0xFF1d1f2e),
                  settingsSectionBackground: Color(0xFF292c3b),
                  dividerColor: Color(0xFF4d5261)),
              sections: [
                SettingsSection(
                  title: Text("", style: TextStyle(fontSize: 0)),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                      title: Transform.translate(
                        offset: Offset(0, 0),
                        child: Text(
                          "3 秒",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),
                      trailing: spinTime == 3
                          ? Icon(
                              Icons.check,
                              color: Color(0xFF1cafff),
                            )
                          : Text(""),
                      onPressed: (context) {
                        pref.then((pref) async {
                          await pref.setInt('spinTime', 3);
                          await pref.setString(
                              'spinTimeText', "3 秒");
                          await Navigator.pushReplacementNamed(context, 'settings');
                        });
                      },
                    ),
                    SettingsTile.navigation(
                        title: Transform.translate(
                          offset: Offset(0, 0),
                          child: Text(
                            "5 秒",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                        trailing: spinTime == 5
                            ? Icon(
                                Icons.check,
                                color: Color(0xFF1cafff),
                              )
                            : Text(""),
                        onPressed: (context) {
                          pref.then((pref) async {
                            await pref.setInt('spinTime', 5);
                            await pref.setString('spinTimeText', "5 秒");
                            await Navigator.pushReplacementNamed(context, 'settings');
                          });
                        }),
                    SettingsTile.navigation(
                        title: Transform.translate(
                          offset: Offset(0, 0),
                          child: Text(
                            "7 秒",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                        trailing: spinTime == 7
                            ? Icon(
                                Icons.check,
                                color: Color(0xFF1cafff),
                              )
                            : Text(""),
                        onPressed: (context) {
                          pref.then((pref) async {
                            await pref.setInt('spinTime', 7);
                            await pref.setString(
                                'spinTimeText', "7 秒");
                            await Navigator.pushReplacementNamed(context, 'settings');
                          });
                        }),
                    SettingsTile.navigation(
                        title: Transform.translate(
                          offset: Offset(0, 0),
                          child: Text(
                            "9 秒",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                        trailing: spinTime == 9
                            ? Icon(
                                Icons.check,
                                color: Color(0xFF1cafff),
                              )
                            : Text(""),
                        onPressed: (context) {
                          pref.then((pref) async {
                            await pref.setInt('spinTime', 9);
                            await pref.setString(
                                'spinTimeText', "9 秒");
                            await Navigator.pushReplacementNamed(context, 'settings');
                          });
                        }),
                    SettingsTile.navigation(
                        title: Transform.translate(
                          offset: Offset(0, 0),
                          child: Text(
                            "12 秒",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                        trailing: spinTime == 12
                            ? Icon(
                                Icons.check,
                                color: Color(0xFF1cafff),
                              )
                            : Text(""),
                        onPressed: (context) {
                          pref.then((pref) async {
                            await pref.setInt('spinTime', 12);
                            await pref.setString(
                                'spinTimeText', "12 秒");
                            await Navigator.pushReplacementNamed(context, 'settings');
                          });
                        }),
                    SettingsTile.navigation(
                        title: Transform.translate(
                          offset: Offset(0, 0),
                          child: Text(
                            "15 秒",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                        trailing: spinTime == 15
                            ? Icon(
                                Icons.check,
                                color: Color(0xFF1cafff),
                              )
                            : Text(""),
                        onPressed: (context) {
                          pref.then((pref) async {
                            await pref.setInt('spinTime', 15);
                            await pref.setString(
                                'spinTimeText', "15 秒");
                            await Navigator.pushReplacementNamed(context, 'settings');
                          });
                        }),
                    SettingsTile.navigation(
                        title: Transform.translate(
                          offset: Offset(0, 0),
                          child: Text(
                            "20 秒",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                        trailing: spinTime == 20
                            ? Icon(
                                Icons.check,
                                color: Color(0xFF1cafff),
                              )
                            : Text(""),
                        onPressed: (context) {
                          pref.then((pref) async {
                            await pref.setInt('spinTime', 20);
                            await pref.setString(
                                'spinTimeText', "20 秒");
                            await Navigator.pushReplacementNamed(context, 'settings');
                          });
                        }),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
