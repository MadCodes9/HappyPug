import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class MySearchResultsPage extends StatefulWidget {
  const MySearchResultsPage({Key? key, required this.title, required this.foundIngred,
  required this.numOfgreenIngred, required this.numOfredIngred, required this.numOfyellowIngred,
  required this.scannedImage, required this.imageUrl})
      : super(key: key);//constructor
  final String title; //attribute
  final Map<String, List<String>> foundIngred;
  final int numOfgreenIngred;
  final int numOfredIngred;
  final int  numOfyellowIngred;
  final Image scannedImage;
  final imageUrl;

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



  @override
  void initState(){
    super.initState();
    setAttributes(); //Access widget attributes
    setButtonColor();//dynamically set background color
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pink[300],
        title: Text(widget.title),
      ),
      body: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(5),
              alignment: Alignment.topLeft,
              height: 200,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.scannedImage,
                    Container(
                        child: Image.network(widget.imageUrl, width: 100)
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
                    style: TextStyle(color: Colors.black, fontSize: 15 * textScale),
                  ),
                  flex: 0,

                ),
                Icon(
                  Icons.report_problem_rounded,
                  color: Colors.yellow,
                ),
                Expanded(
                  child: Text(
                    "${widget.numOfyellowIngred} Caution",
                    style: TextStyle(color: Colors.black, fontSize: 15 * textScale),
                  ),
                  flex: 0,

                ),
                Icon(
                  Icons.close_rounded,
                  color: Colors.red,
                ),
                Expanded(
                  child: Text(
                    //"${widget.text.values.elementAt(0).elementAt(1)} Bad",
                    "${widget.numOfredIngred} Unhealthy",
                    style: TextStyle(color: Colors.black, fontSize: 15 * textScale),
                  ),
                  //flex: 0,
                ),
              ],
            ),

            Row(
              children: [
                ButtonTheme(
                  child: TextButton.icon(
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey,
                    ),
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
                      primary: Colors.white,
                      backgroundColor: Colors.white,
                    ): TextButton.styleFrom(
                      shape: BeveledRectangleBorder(),
                      primary: Colors.transparent,
                      backgroundColor: Colors.pink[300],
                    ),
                    label: Text(
                        "Analysis",
                        style: pressed1
                        ?TextStyle(
                            color: Colors.black,
                            fontSize: 15 * textScale,
                            fontWeight: FontWeight.bold
                        ): TextStyle(
                            color: Colors.white,
                            fontSize: 15 * textScale,
                            fontWeight: FontWeight.bold,
                        )
                    ),

                  ),
                ),

                ButtonTheme(
                  child: TextButton.icon(
                    label: Text(
                        "Ingredients",
                        style:
                        TextStyle(color: Colors.black, fontSize: 15 * textScale, fontWeight: FontWeight.bold)),
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
                      primary: Colors.white,
                      backgroundColor: Colors.white,
                    ): TextButton.styleFrom(
                      shape: BeveledRectangleBorder(),
                      primary: Colors.transparent,
                      backgroundColor: Colors.pink[50],
                    ),

                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey,
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
                  SingleChildScrollView(//scrollable content
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
                                          color: Colors.white,
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
                                                style: TextStyle(fontSize: 18 * textScale, fontWeight: FontWeight.bold),
                                              )),
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
                                                      color: Colors.yellow,
                                                    ),
                                                  ),

                                                  Text(
                                                      "Description",
                                                      style: TextStyle(fontSize: 15 * textScale, fontWeight: FontWeight.bold),
                                                      textAlign: TextAlign.left
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                  child:  Text(
                                                    "${results[ingredient]?.elementAt(0)}",
                                                    style: TextStyle(height: 1.5, fontSize: 15 * textScale),

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
        btnColor[keys[i]] = Colors.yellow;
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
          style: TextStyle(fontSize: 15 * textScale, fontWeight: FontWeight.bold)
      );
    }
    else if (ratingColor== "MaterialColor(primary value: Color(0xffffeb3b))"){
      return rating = Text(
          "Not Recommended",
          style: TextStyle(fontSize: 15 * textScale, fontWeight: FontWeight.bold)
      );
    }
    else if (ratingColor == "MaterialColor(primary value: Color(0xfff44336))"){
      return rating = Text(
          "Avoid",
          style: TextStyle(fontSize: 15 * textScale, fontWeight: FontWeight.bold)
      );
    }
    else{
      return rating = Text(
          "Neutral",
          style: TextStyle(fontSize: 15 * textScale, fontWeight: FontWeight.bold)
      );
    }
  }

}

