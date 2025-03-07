import 'dart:math';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spinner/pages/add_wheel.dart';
import 'package:spinner/pages/home.dart';
import 'package:spinner/pages/settings.dart';
import 'package:spinner/pages/wheels.dart';

void main() {
  // HttpOverrides.global = MyHttpOverrides();
  runApp(const MyAPP());
}

class MyAPP extends StatefulWidget {
  const MyAPP({super.key});

  @override
  State<MyAPP> createState() => _MyAPPState();
}

class _MyAPPState extends State<MyAPP> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Spinning Wheel',
        home: HomeScreen(
          // wheel: {},
        ),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor:
              MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? Color(0xFF1d1f2e)
                  : Color(0xFF1d1f2e),
                  // : Color(0xFFFFFFFF),
          brightness: MediaQuery.of(context).platformBrightness,
          fontFamily: 'Helvetica-neu-bold',
          switchTheme: SwitchThemeData(
            thumbColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
              return Colors. white;
            }),
            trackColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
              if (states. contains(WidgetState. selected)) {
                return CupertinoColors.activeGreen;
              }
              return CupertinoColors.systemGrey2;
            }),
          )
        ),
        localizationsDelegates: [
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        routes: {
          'add-new-wheel': (BuildContext context) {
            return AddWheelScreen(slices: [
              {
                'id': Random.secure().nextInt(1000),
                'color': '#fb6e74',
                'name': '',
                'weight': '1',
                'order': 1,
              },
              {
                'id': Random.secure().nextInt(1000),
                'color': '#fbe05d',
                'name': '',
                'weight': '1',
                'order': 2,
              }
            ], wheelTitle: "");
          },
          'settings': (BuildContext context) {
            return SettingsScreen();
          },
          'wheels' : (BuildContext context){
            return WheelsScreen();
          }
        });
  }
}
