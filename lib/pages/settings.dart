import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spinner/pages/times.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<SharedPreferences> pref = SharedPreferences.getInstance();
  late bool remove_once_chosen = true;
  late String spinTimeText = "9 sec: Normal";

  @override
  void initState() {
    super.initState();
    pref.then((pref) {
      setState(() {
        remove_once_chosen = pref.getBool('removeOnceChosen') ?? true;
        spinTimeText = pref.getString('spinTimeText') ?? "9 sec: Normal";
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
          onPressed: () async {
            Navigator.popAndPushNamed(context, '/');
          },
          child: Icon(
            CupertinoIcons.multiply,
            color: Color(0xFF1cafff),
            size: 46,
          ),
        ),
        middle: Text(
          "設定", // "Settings",

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
              applicationType: ApplicationType.cupertino,
              darkTheme: SettingsThemeData(
                  settingsListBackground: Color(0xFF1d1f2e),
                  settingsSectionBackground: Color(0xFF292c3b),
                  dividerColor: Color(0xFF4d5261)),
              sections: [
                SettingsSection(
                  title: Text(
                    "",
                    style: TextStyle(fontSize: 0),
                  ),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                      // leading: Icon(Icons.auto_awesome),
                      leading: Image.asset(
                        'images/auto-awesome.png',
                        height: 30,
                      ),
                      title: Transform.translate(
                        offset: Offset(0, 0),
                        child: Text(
                          "高級包",//"Premium Pack",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    )
                  ],
                ),
                SettingsSection(
                  title: Text("Current Wheel Settings",
                      style:
                          TextStyle(fontSize: 15, fontFamily: 'Helvetica-nue')),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                      onPressed: (context) {
                        Navigator.push(context,
                            CupertinoPageRoute(builder: (context) {
                          return TimesScreen();
                        }));
                      },
                      leading: Icon(
                        CupertinoIcons.timer,
                        color: Colors.white,
                      ),
                      title: Transform.translate(
                        offset: Offset(0, 0),
                        child: Text(
                          "Spin Time",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      trailing: Text(spinTimeText,
                          style: TextStyle(
                              fontSize: 16, fontFamily: 'Helvetica-nue')),
                    ),
                    SettingsTile.navigation(
                      // leading: Icon(CupertinoIcons.music_note),
                      leading: Image.asset(
                        'images/music.png',
                        width: 27,
                      ),
                      title: Transform.translate(
                        offset: Offset(0, 0),
                        child: Text(
                          "BGM",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      trailing: Text("Drum Roll 1",
                          style: TextStyle(
                              fontSize: 16, fontFamily: 'Helvetica-nue')),
                    ),
                    SettingsTile.navigation(
                      leading: Icon(
                        CupertinoIcons.speaker_2,
                        color: Colors.white,
                      ),
                      title: Transform.translate(
                        offset: Offset(0, 0),
                        child: Text(
                          "Decision Sound",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      trailing: Text("SFX1 Cymbal",
                          style: TextStyle(
                              fontSize: 16, fontFamily: 'Helvetica-nue')),
                    ),
                    SettingsTile.navigation(
                      // leading: SvgPicture.asset(
                      //   "svg/duality-mask.svg",
                      //   height: 20,
                      //   color: Color(0xFFC3C3C3),
                      // ),
                      leading: Image.asset(
                        'images/dual-face.png',
                        width: 35,
                      ),
                      title: Transform.translate(
                        offset: Offset(-5, 0),
                        child: Text(
                          "Effect",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      trailing: Text("Shift (1 before)",
                          style: TextStyle(
                              fontSize: 16, fontFamily: 'Helvetica-nue')),
                    ),
                    SettingsTile.navigation(
                      // leading: Icon(Icons.casino_outlined),
                      leading: Image.asset(
                        'images/dice.png',
                        width: 26,
                      ),
                      title: Transform.translate(
                        offset: Offset(0, 0),
                        child: Text(
                          "Effect Frequency",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      trailing: Text("0%",
                          style: TextStyle(
                              fontSize: 16, fontFamily: 'Helvetica-nue')),
                    ),
                    SettingsTile.switchTile(
                      // leading: Icon(Icons.rounded_corner_sharp),
                      leading: Image.asset(
                        'images/select-area.png',
                        width: 25,
                      ),
                      title: Transform.translate(
                        offset: Offset(0, 0),
                        child: Text(
                          "Remove Once Chosen",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      initialValue: remove_once_chosen,
                      onToggle: (value) async {
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        setState(() {
                          remove_once_chosen = value;
                          pref.setBool('removeOnceChosen', value);
                        });
                      },
                    ),
                    SettingsTile.switchTile(
                      // leading: Icon(Icons.touch_app_outlined),
                      leading: Image.asset(
                        'images/tap.png',
                        width: 27,
                      ),
                      title: Transform.translate(
                        offset: Offset(0, 0),
                        child: Text(
                          "Tap to Stop",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      initialValue: false,
                      onToggle: (value) {
                        print('ssdd');
                        print(value);
                      },
                    )
                  ],
                ),
                SettingsSection(
                  title: Text('Default',
                      style:
                          TextStyle(fontSize: 15, fontFamily: 'Helvetica-nue')),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                        leading: Transform.rotate(
                          angle: 13,
                          child: SvgPicture.asset(
                            "svg/settings.svg",
                            height: 25,
                            color: Colors.white,
                          ),
                        ),
                        title: Transform.translate(
                          offset: Offset(0, 0),
                          child: Text(
                            "Default Settings",
                            style: TextStyle(fontSize: 15),
                          ),
                        )),
                  ],
                ),
                SettingsSection(
                  title: Text(
                    '',
                    style: TextStyle(fontSize: 0),
                  ),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                        leading: Icon(Icons.help_outline),
                        title: Transform.translate(
                          offset: Offset(0, 0),
                          child: Text(
                            "Help",
                            style: TextStyle(fontSize: 15),
                          ),
                        )),
                    SettingsTile.navigation(
                        leading: Icon(Icons.info_outline_rounded),
                        title: Transform.translate(
                          offset: Offset(0, 0),
                          child: Text(
                            "App Information",
                            style: TextStyle(fontSize: 15),
                          ),
                        )),
                    SettingsTile.navigation(
                        leading: Icon(Icons.dark_mode_outlined),
                        title: Transform.translate(
                          offset: Offset(0, 0),
                          child: Text(
                            "Dark Mode",
                            style: TextStyle(fontSize: 15),
                          ),
                        )),
                    SettingsTile.navigation(
                        leading: Icon(Icons.lock_outline),
                        title: Transform.translate(
                          offset: Offset(0, 0),
                          child: Text(
                            "Passcode Lock",
                            style: TextStyle(fontSize: 15),
                          ),
                        )),
                    SettingsTile.navigation(
                        leading: Icon(Icons.language_outlined),
                        title: Transform.translate(
                          offset: Offset(0, 0),
                          child: Text(
                            "Languages",
                            style: TextStyle(fontSize: 15),
                          ),
                        )),
                  ],
                ),
                SettingsSection(
                  title: Text('Simple Series Apps',
                      style:
                          TextStyle(fontSize: 15, fontFamily: 'Helvetica-nue')),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                        leading: Image.asset(
                          'images/ic_calendar.png',
                          height: 20,
                        ),
                        title: Transform.translate(
                          offset: Offset(0, 0),
                          child: Text(
                            "Simple Calendar (AD)",
                            style: TextStyle(fontSize: 15),
                          ),
                        )),
                    SettingsTile.navigation(
                        leading: Image.asset(
                          'images/ic_smart_diet.png',
                          height: 20,
                        ),
                        title: Transform.translate(
                          offset: Offset(0, 0),
                          child: Text(
                            "Smart Diet (AD)",
                            style: TextStyle(fontSize: 15),
                          ),
                        )),
                    SettingsTile.navigation(
                        leading: Image.asset(
                          'images/ic_kakeibo.png',
                          height: 20,
                        ),
                        title: Transform.translate(
                          offset: Offset(0, 0),
                          child: Text(
                            "Monthly Note (AD)",
                            style: TextStyle(fontSize: 15),
                          ),
                        )),
                    SettingsTile.navigation(
                        leading: Image.asset(
                          'images/ic_simple_diary.png',
                          height: 20,
                        ),
                        title: Transform.translate(
                          offset: Offset(0, 0),
                          child: Text(
                            "Simple Diary (AD)",
                            style: TextStyle(fontSize: 15),
                          ),
                        )),
                    SettingsTile.navigation(
                        leading: Image.asset(
                          'images/img.png',
                          height: 20,
                        ),
                        title: Transform.translate(
                          offset: Offset(0, 0),
                          child: Text(
                            "Simple Notepad (AD)",
                            style: TextStyle(fontSize: 15),
                          ),
                        )),
                    SettingsTile.navigation(
                        leading: Image.asset(
                          'images/ic_n_calendar.png',
                          height: 20,
                        ),
                        title: Transform.translate(
                          offset: Offset(0, 0),
                          child: Text(
                            "N Calendar (AD)",
                            style: TextStyle(fontSize: 15),
                          ),
                        ))
                  ],
                ),
                SettingsSection(
                    tiles: [SettingsTile(title: Text("© 轉盤+ ver 2.2.1"))])
              ],
            ),
          )
        ],
      ),
    );
  }
}
