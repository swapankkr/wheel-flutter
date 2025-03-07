import 'package:flutter/cupertino.dart';

class ColorPickerScreen extends StatefulWidget {
  ColorPickerScreen({super.key, required this.currentColor, required this.selectedColors, required this.onChange});
  final currentColor;
  final selectedColors;
  final Function onChange;

  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState(currentColor: currentColor, selectedColors: selectedColors, onChange: onChange);
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  var currentColor;
  final List selectedColors;
  final onChange;
  _ColorPickerScreenState({required this.currentColor, required this.selectedColors, required this.onChange});
  var colors = [
    ["#fb6e74", "#fbe05d", "#8aecb3", "#80e2fb", "#b48cee"],
    ["#f784bb", "#f9bc51", "#52bc7a", "#7b9ce9", "#b473c3"],
    ["#f66e78", "#faa94e", "#87e0a0", "#81ebf9", "#b087cb"],
    ["#f95e7d", "#f2e45d", "#74ce98", "#1ee2de", "#a680bb"],
    ["#f5515a", "#e8d26c", "#61b584", "#7bdbd7", "#9f70a7"],
    ["#f47f9c", "#e8b951", "#8bc53d", "#71ccbd", "#7b71c8"],
    ["#df76a1", "#f89753", "#84b537", "#61d0e3", "#6b66b6"],
    ["#de5eb3", "#f6a800", "#7aa52f", "#0daffa", "#554ba2"],
    ["#f343d2", "#ee9118", "#778e22", "#048ce4", "#454092"],
    ["#f240a2", "#db7a19", "#626e2c", "#ffffff", '#000000']
  ];

  Color _getColor(String hexColorCode) {
    return Color.fromRGBO(
        int.parse(hexColorCode.substring(1, 3), radix: 16),
        int.parse(hexColorCode.substring(3, 5), radix: 16),
        int.parse(hexColorCode.substring(5, 7), radix: 16),
        1);
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
              CupertinoIcons.back,
              color: Color(0xFF168afd),
              size: 46,
            ),
          ),
        ),
        backgroundColor: Color(0xFF1d1f2e),
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(width: 0.5, color: Color(0xFF707090)))),
            child: ListView(
                children: colors.map((rowColors) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                    spacing: 15,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: rowColors.map((color) {
                      var is_current = color == currentColor;
                      var is_active = selectedColors.contains(color);
                      return Expanded(
                        child: GestureDetector(
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getColor(color),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              border: is_current ? Border.all( color: CupertinoColors.systemBlue, width: 3) : Border.all(width: 0)
                            ),
                            height: 55,
                            // width: 55,
                            child: Center(
                              child: is_active ? Icon(
                                CupertinoIcons.checkmark_alt,
                                size: 30,
                                color: color == '#ffffff' ? CupertinoColors.black : CupertinoColors.white,
                              ) : Text(''),
                            ),
                          ),
                          onTap: (){
                            setState(() {
                              currentColor = color;
                            });
                            onChange(color);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }).toList()),
              );
            }).toList()),
          ),
        ));
  }
}
