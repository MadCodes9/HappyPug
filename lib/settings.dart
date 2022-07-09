import 'package:flutter/material.dart';
import 'package:day_night_switcher/day_night_switcher.dart';

class MySettingsPage extends StatefulWidget {
  const MySettingsPage({Key? key, required this.title}) : super(key: key);//constructor
  final String title; //attribute

  @override
  State<MySettingsPage> createState() => _MySettingsPageState();
}

class _MySettingsPageState extends State<MySettingsPage> {
  bool isDarkModeEnabled = false;
  int? _fontSize = 10;
  @override
  Widget build(BuildContext context) {  //entire UI
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,  //alignment
            children: <Widget>[
              ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: ListTile.divideTiles(
                      context: context,
                      tiles:[
                        ListTile(
                          leading: Icon(Icons.brightness_6_rounded),
                          subtitle: Text("Change the appearance to dark or light theme"),
                          trailing: Transform.scale(
                            scale: 0.8,
                            child: DayNightSwitcher(
                              isDarkModeEnabled: isDarkModeEnabled,
                              onStateChanged: onStateChanged,
                              dayBackgroundColor: Colors.white24,
                            ),
                          ),
                          title: Text(
                              "Appearance"
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.text_fields_rounded),
                          title: Text("Text Size"),
                          subtitle: Text("Change the text size to smaller or larger font"),
                          trailing: Icon(Icons.keyboard_arrow_right_rounded),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4)),
                                    elevation: 16,
                                    child: Container(
                                      decoration: BoxDecoration( //decorate popup
                                        // color: widget.isDarkModeEnabled ?Colors.grey[800]: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                  0.5),
                                              spreadRadius: 2,
                                              blurRadius: 7,
                                              offset: Offset(2, 3),
                                            ),
                                          ]
                                      ),
                                      child:
                                      ListView(
                                        padding: EdgeInsets.all(10),
                                        shrinkWrap: true,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text("Font Size"),
                                              // RadioListTile<int>(
                                              //   value: 10,
                                              //   groupValue: _fontSize,
                                              //   title: Text("Small"),
                                              //   onChanged: (val){
                                              //     _fontSize = val;
                                              //   },
                                              //   activeColor: Colors.red,
                                              //   selected: false,
                                              // ),
                                              // RadioListTile<int>(
                                              //   value: 15,
                                              //   groupValue: _fontSize,
                                              //   title: Text("Normal"),
                                              //   onChanged: (val){
                                              //     setSelectedRadio(val);
                                              //   },
                                              //   activeColor: Colors.red,
                                              //   selected: false,
                                              // ),
                                              // RadioListTile<int>(
                                              //   value: 20,
                                              //   groupValue: _fontSize,
                                              //   title: Text("Large"),
                                              //   onChanged:  (val){
                                              //     setSelectedRadio(val);
                                              //   },
                                              //   activeColor: Colors.red,
                                              //   selected: false,
                                              // ),
                                              // RadioListTile<int>(
                                              //   value: 25,
                                              //   groupValue: _fontSize,
                                              //   title: Text("Extra Large"),
                                              //   onChanged:  (val){
                                              //     setSelectedRadio(val);
                                              //   },
                                              //   activeColor: Colors.red,
                                              //   selected: false,
                                              // ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          }),

                        ListTile(
                          leading: Icon(Icons.lock_rounded),
                          title: Text("Privacy & Security"),
                          trailing: Icon(Icons.keyboard_arrow_right_rounded),
                        ),
                        ListTile(
                          leading: Icon(Icons.help),
                          title: Text("About"),
                          trailing: Icon(Icons.keyboard_arrow_right_rounded),

                        )
                      ]
                  ).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }



  ThemeData lightTheme(){
    return ThemeData(
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.deepPurple[200],
      ),
      scaffoldBackgroundColor: Colors.grey[50],
      primaryColor: Colors.white,
      brightness: Brightness.light,
      dividerColor: Colors.white54,
    );
  }
  ThemeData darkTheme(){
    return ThemeData(
      appBarTheme: AppBarTheme(color: const Color(0xFF253341)),
      scaffoldBackgroundColor: const Color(0xFF15202B),
      primarySwatch: Colors.grey,
      primaryColor: const Color(0xFF253341),
      brightness: Brightness.dark,
      backgroundColor: const Color(0xFF212121),
      dividerColor: Colors.black12,
    );
  }

  void onStateChanged(bool isDarkModeEnabled) {
    setState(() {
      this.isDarkModeEnabled = isDarkModeEnabled;
    });
  }
}

