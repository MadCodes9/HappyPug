import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';

class MySearchResultsPage extends StatefulWidget {
  const MySearchResultsPage({Key? key, required this.title, required this.foundIngred,
  required this.numOfgreenIngred, required this.numOfredIngred, required this.numOfyellowIngred,
  required this.scannedImage, required this.imageUrl, required this.isDarkModeEnabled,
  required this.grade, required this.gradeColor})
      : super(key: key);//constructor
  final String title; //attribute
  final Map<String, List<String>> foundIngred;
  final int numOfgreenIngred;
  final int numOfredIngred;
  final int  numOfyellowIngred;
  final Image scannedImage;
  final bool isDarkModeEnabled;
  final  Map<String, double> grade;
  final imageUrl;
  final Color gradeColor;

  @override
  State<MySearchResultsPage> createState() => _MySearchResultsState();
}

class _MySearchResultsState extends State<MySearchResultsPage> {
  Map<String, List<String>> results = {};
  List<String> keys = [];
  bool _isVisible = false;
  bool pressed1 = true;
  bool pressed2 = true;
  Text rating = Text("");
  final Map<String,Color> btnColor = {};
  Map<String,double> map = {};


  @override
  void initState(){
    super.initState();
    setAttributes(); //Access widget attributes
    setButtonColor();//dynamically set background color
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: widget.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light,

      home:  Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: TextStyle(color: Colors.white)),
        ),
        body: Column(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.all(5),
                  height: 200,
                  child: Padding(
                     padding: EdgeInsets.all(5),
                     child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Expanded(
                           flex: 0,
                           child: Container(
                             alignment: Alignment.topLeft,
                             child: widget.scannedImage,
                           )
                         ),
                         //display pug image along with overall rating
                         if(widget.imageUrl != null)
                           Expanded(
                             flex: 1,
                               child: Container(
                                 alignment: Alignment.center,
                                 child: Column(
                                   children: [
                                      Image.network(
                                       widget.imageUrl,
                                       width: 100,
                                      ),//BLEND THE EDGES
                                     Text("Ingredient Rating",
                                         style: TextStyle(
                                             fontWeight: FontWeight.bold,
                                             fontSize: 15 * textScale,

                                         )),
                                      Container(
                                        width: 50,
                                        height: 50,
                                        child: Column(

                                          children: [
                                            Text(
                                                "${widget.grade.keys.elementAt(0)}",
                                                style: TextStyle(
                                                  fontSize: 15 * textScale,
                                                )
                                            ),
                                            Text(
                                                "${widget.grade.values.elementAt(0).toStringAsFixed(1)}%",
                                                style: TextStyle(
                                                  fontSize: 15 * textScale,
                                                )
                                            )
                                          ],
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: widget.gradeColor,
                                        ),
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.all(0.5),
                                      ),
                                   ],
                                 )
                               )
                           )
                       ],
                     )
                 )

              ),
              // Container(
              //
              //
              //   child:
              //
              //   // Image(
              //   //   height: 200,
              //   //   width: 200,
              //   //  // image: NetworkImage('https://i.pinimg.com/originals/53/cb/23/53cb231f4c04ae30a04a6e292eb2a48c.jpg'),
              //   // ),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_rounded,
                    color: Colors.lightGreen,
                  ),
                  Expanded(
                    child: Text(
                      "${widget.numOfgreenIngred} Healthy",
                      style: TextStyle(color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900],
                          fontSize: 15 * textScale),
                    ),
                    flex: 0,

                  ),
                  Icon(
                    Icons.report_problem_rounded,
                    color: Colors.amber,
                  ),
                  Expanded(
                    child: Text(
                      "${widget.numOfyellowIngred} Caution",
                      style: TextStyle(color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900],
                          fontSize: 15 * textScale),
                    ),
                    flex: 0,

                  ),
                  Icon(
                    Icons.close_rounded,
                    color: Colors.red,
                  ),
                  Expanded(
                    child: Text(
                      "${widget.numOfredIngred} Unhealthy",
                      style: TextStyle(color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900],
                          fontSize: 15 * textScale),
                    ),
                    //flex: 0,
                  ),
                ],
              ),

              Row(
                children: [
                  ButtonTheme(
                    child: TextButton.icon(
                      label: Text(
                          "Analysis",
                          style:
                          TextStyle(color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900],
                              fontSize: 15 * textScale, fontWeight: FontWeight.bold)),
                      onPressed: (){
                        setState((){
                          pressed1 = !pressed1;
                          _isVisible = false;
                        });
                        pressed2 = true;
                      },
                      style: pressed1 //Analysis btn decoration on press
                          ?TextButton.styleFrom(
                        shape: BeveledRectangleBorder(),

                      ): TextButton.styleFrom(
                        shape: BeveledRectangleBorder(),
                        primary: Colors.blueGrey[900],
                        backgroundColor: widget.isDarkModeEnabled ?Colors.grey: Colors.deepPurple[50],
                      ),

                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: pressed1 ?Colors.grey: Color(0xFF212121),
                      ),


                    ),
                  ),

                  ButtonTheme(
                    child: TextButton.icon(
                      label: Text(
                          "Ingredients",
                          style:
                          TextStyle(color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900],
                              fontSize: 15 * textScale, fontWeight: FontWeight.bold)),
                      onPressed: (){
                        setState((){
                          pressed2 = !pressed2;
                        });
                        //Ingredient btn is pressed so unpress Analysis btn
                        pressed1 = true;
                        showText(); //Controls visibility
                      },
                      style: pressed2 //Ingredients btn decoration on press
                          ?TextButton.styleFrom(
                        shape: BeveledRectangleBorder(),

                      ): TextButton.styleFrom(
                        shape: BeveledRectangleBorder(),
                        primary: Colors.blueGrey[900],
                        backgroundColor: widget.isDarkModeEnabled ?Colors.grey: Colors.deepPurple[50],
                      ),

                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: pressed2 ?Colors.grey: Color(0xFF212121),
                      ),
                    ),
                  ),
                ],
              ),



              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child:
                  Visibility( //show and hide ingredients
                    visible: _isVisible,
                    child:
                    SingleChildScrollView( //scrollable content
                      padding: EdgeInsets.all(8.0),
                      scrollDirection: Axis.vertical,
                      child:
                      Column(  //dynamically display ingredients
                          mainAxisSize: MainAxisSize.min,
                          children:
                          keys.map((String ingredient) => TextButton.icon(
                            onPressed: (){  //popup show description, rating when ingredient is pressed
                              showDialog(
                                  context: context,
                                  builder: (context){
                                    return Dialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      elevation: 16,
                                      child: Container(
                                        decoration: BoxDecoration(  //decorate popup
                                            //color: Colors.grey[50],
                                            color: widget.isDarkModeEnabled ?Colors.grey: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 7,
                                                offset: Offset(2,3),
                                              ),
                                            ]
                                        ),
                                        child: ListView(
                                          padding: EdgeInsets.all(10),
                                          shrinkWrap: true,
                                          children: [
                                            SizedBox(height: 20),
                                            Center(//display ingredient name
                                                child: Text(
                                                    ingredient,
                                                    style: TextStyle(fontSize: 18 * textScale, fontWeight: FontWeight.bold,
                                                        color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]))
                                            ),
                                            Column( //display ingredient description
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 12),
                                                Container(height: 2),
                                                Row(  //display ingredient description
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(left: 4.0),
                                                      child:  Icon(
                                                        Icons.lightbulb,
                                                        color: Colors.amber,
                                                      ),
                                                    ),

                                                    Text(
                                                        "Description",
                                                        style: TextStyle(fontSize: 15 * textScale, fontWeight: FontWeight.bold,
                                                            color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                        textAlign: TextAlign.left
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                    child:  Text(
                                                      "${results[ingredient]?.elementAt(0)}",
                                                      style: TextStyle(height: 1.5, fontSize: 15 * textScale, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),

                                                    )
                                                ),
                                                Row(  //display ingredient rating
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(left: 4.0),
                                                      child:  Icon(
                                                        Icons.health_and_safety_rounded,
                                                        color: btnColor[ingredient],
                                                      ),
                                                    ),
                                                    displayRating(btnColor[ingredient].toString(), textScale)
                                                  ],
                                                ),
                                              ],
                                            )

                                          ],
                                        ),
                                      ),
                                    );
                                  }
                              );
                            },

                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(btnColor[ingredient]),
                              fixedSize: MaterialStateProperty.all(Size.fromWidth(350)),
                            ),

                            label: Align( //display ingredient name button
                                alignment: Alignment.topLeft,
                                child: Text(
                                    ingredient,
                                    style: TextStyle(color: Colors.white, fontSize: 15 * textScale, fontWeight: FontWeight.bold))
                            ),
                            icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black54
                            ),
                          )).toList()
                      ),
                    ),

                  ),
                ),

              ),




              //
              // ElevatedButton(
              //     onPressed: (){  //load data from firestore database
              //       FirebaseFirestore.instance.collection("ingredients").get()
              //           .then((querySnapshot) {
              //         print("Successfully load all ingredients");
              //         //print querySnapshot
              //         querySnapshot.docs.forEach((element) {
              //           //print(element.data());
              //           print(element.data()['name']);
              //         });
              //       }).catchError((error){
              //         print("Fail to load all ingredients");
              //         print(error);
              //       });
              //     },
              //     child: Text("List all ingredients")
              // )
            ]
        ),
      ),
    );
  }

  void setAttributes() {
      results = widget.foundIngred;
      keys = widget.foundIngred.keys.toList();

  }

  //store ingredient name and color pair in Map to set the color of the dynamic buttons
  void setButtonColor(){
    for(var i = 0; i < keys.length; i++){
      if(results.values.elementAt(i).elementAt(1) == "green"){
        btnColor[keys[i]] = Colors.green;
      }
      else if (results.values.elementAt(i).elementAt(1) == "yellow"){
        btnColor[keys[i]] = Colors.amber;
      }
      else if (results.values.elementAt(i).elementAt(1) == "red"){
        btnColor[keys[i]] = Colors.red;
      }
      else{
        btnColor[keys[i]] = Colors.lightBlueAccent;
      }
    }
  }
  void showText(){
    setState((){
      _isVisible = !_isVisible;
    });
  }
  Text displayRating(String ratingColor, double textScale){
    if(ratingColor == "MaterialColor(primary value: Color(0xff4caf50))"){
      return rating = Text(
          "Recommended",
          style: TextStyle(fontSize: 15 * textScale, fontWeight: FontWeight.bold,
              color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
      );
    }
    else if (ratingColor== "MaterialColor(primary value: Color(0xffffc107))"){
      return rating = Text(
          "Not Recommended",
          style: TextStyle(fontSize: 15 * textScale, fontWeight: FontWeight.bold,
              color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
      );
    }
    else if (ratingColor == "MaterialColor(primary value: Color(0xfff44336))"){
      return rating = Text(
          "Avoid",
          style: TextStyle(fontSize: 15 * textScale, fontWeight: FontWeight.bold,
              color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
      );
    }
    else{
      return rating = Text(
          "Neutral",
          style: TextStyle(fontSize: 15 * textScale, fontWeight: FontWeight.bold,
              color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
      );
    }
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

}

