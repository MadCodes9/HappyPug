import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:happy_pug/data_base.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:happy_pug/search_results.dart';
import 'firebase_options.dart';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';
import 'package:recase/recase.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:google_fonts/google_fonts.dart';


//void main() => runApp(MyApp()); //lambda expression same as below format
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget { //global data, style of entire app
  MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Home' ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);//constructor
  final String title; //attribute

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  bool textScanning = false;
  bool isDarkModeEnabled = false;
  XFile? imageFile;
  String scannedText = "";
  Map<String, List<String>> results = {};
  String greenIngred = "";
  String redIngred = "";
  String yellowIngred = "";
  int numOfGreenIngred = 0;
  int numOfRedIngred = 0;
  int numOfYellowIngred = 0;
  bool onClick = false;
  Map<String, double> grade = {};
  Color gradeColor = Colors.transparent;
  var pugImageUrl;
  String uploadPugImage = "";
  var ingredientImageUrl;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Home",
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(

        appBar: AppBar(
          //centerTitle: true,
          title:  Text("Happy Pug", textAlign: TextAlign.left, style: GoogleFonts.pacifico(fontSize: 25, fontWeight: FontWeight.w500)),
          actions: [
            Transform.scale(
              scale: 0.8,
              child: DayNightSwitcher(
                isDarkModeEnabled: isDarkModeEnabled,
                onStateChanged: onStateChanged,
                dayBackgroundColor: Colors.white24,
              ),
            ),
          ],
        ),
        body: Center(
            child: SingleChildScrollView(
              child: Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if(!textScanning && imageFile == null)
                        Column(
                          children: [
                            Text("Scan Ingredients", style: TextStyle(fontSize: 18 * textScale,
                            fontWeight: FontWeight.bold)
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5,right: 5,top: 6, bottom: 20),
                              child: Text("Focus camera on the back of ingredient list of your dog food product like below",
                                style: TextStyle(fontSize: 15 * textScale)),
                            ),

                          ],

                        ),
                      if (!textScanning && imageFile == null)
                        Container(  //Template container
                          width: 270,
                          height: 388,
                          color: Colors.grey[300]!,
                          child: FutureBuilder(
                            future: loadIngredientListImage(),
                              builder: (context, snapshot){
                                if(snapshot.connectionState == ConnectionState.done){
                                   return Image.network(ingredientImageUrl);
                                }
                                if(snapshot.connectionState == ConnectionState.waiting){
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return Container();
                              }
                          ),

                        ),

                      if (imageFile != null)
                        Column(

                          children: [
                            Padding(
                              padding: EdgeInsets.all(10),
                              child:
                              Text("Scanned Image", style: TextStyle(fontSize: 18 * textScale,
                                  fontWeight: FontWeight.bold)
                              ),
                            ),
                            Stack( //display scanned image
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 300,
                                  height: 400,
                                  child: Image.file(File(imageFile!.path)),
                                ),
                                if (textScanning)
                                  Column(
                                    children: [
                                      Text("Processing...", style: TextStyle(fontSize: 18 * textScale,
                                          fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ],
                                  )

                              ],
                            ),
                          ],
                        ),

                      Row(  //UI
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Container(  //Gallery button
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              padding: const EdgeInsets.only(top: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.grey[400],
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),
                                ),
                                onPressed: () {
                                  getImage(ImageSource.gallery);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.image,
                                        size: 30,
                                      ),
                                      Text(
                                        "Gallery",
                                        style: TextStyle(
                                            fontSize: 14 * textScale,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                          ),
                          Container(  //Camera button
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              padding: const EdgeInsets.only(top: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shadowColor: Colors.grey[400],
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),
                                ),
                                onPressed: () {
                                  getImage(ImageSource.camera);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 30,
                                      ),
                                      Text(
                                        "Camera",
                                        style: TextStyle(
                                            fontSize: 14 * textScale,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ),
                      // const SizedBox(
                      //   height: 20,
                      // ),
                      // Container(  //display results
                      //   child: Text(
                      //     scannedText,
                      //     style: TextStyle(fontSize: 20),
                      //   ),
                      // )
                      if(textScanning == false && imageFile != null)//once loading is done display buttons
                        Column(
                            children:<Widget>[
                              Container(
                                child:
                                Padding(
                                    padding: EdgeInsets.all(10),
                                    child: ElevatedButton(
                                        onPressed: (){
                                          if(onClick == false){ //user can press btn only once
                                            //filter ingredients then calculate the ingredient rating
                                            // then load image from real time database and go to result page
                                            _filterIngredients().then((value) => calculateOverallRating()).
                                            then((value) => loadPugImage()).then((value) => searchResultsPage());
                                          }
                                          onClick = true;
                                        },
                                        child: Text('View Results', style: TextStyle(fontSize: 14 * textScale))
                                    ),
                                ),
                              ),

                              Container(
                                child:
                                ElevatedButton(
                                    onPressed: () => loginPage(),
                                    child: Text(
                                      'login_page',
                                    )
                                ),
                              ),

                              Container(
                                child: ElevatedButton(
                                    onPressed: () => databasePage(),
                                    child: Text(
                                      'data_base',
                                    )
                                ),
                              ),
                            ]
                        ),
                    ],
                  )),
            )),
      ),
    );
  }
  FutureOr reset(){ //reset all counters
    numOfGreenIngred = 0;
    numOfRedIngred = 0;
    numOfYellowIngred = 0;
    onClick = false;
    grade = {};
    setState((){});
  }
  void seperateByColorIngredients(){
    for(var i = 0; i < results.keys.length; i++){
      if(results.values.elementAt(i).elementAt(1) == "green"){//if name.color == green
        greenIngred = results.values.elementAt(i).elementAt(1);
        numOfGreenIngred++;
        print(results.keys.elementAt(i) + " is " + results.values.elementAt(i).elementAt(1));
      }
      if(results.values.elementAt(i).elementAt(1) == "red"){//if name.color == red
        redIngred =  results.values.elementAt(i).elementAt(1);
        numOfRedIngred++;
        print(results.keys.elementAt(i) + " is " + results.values.elementAt(i).elementAt(1));
      }
      if(results.values.elementAt(i).elementAt(1) == "yellow"){//if name.color == yellow
        yellowIngred = results.values.elementAt(i).elementAt(1);
        numOfYellowIngred++;
        print(results.keys.elementAt(i) + " is " + results.values.elementAt(i).elementAt(1));
      }
    }

  }

  Future _filterIngredients() async {
    String trim_ingredients = scannedText.replaceAll(new RegExp(r"\s+"), ""); //delete all white space
    trim_ingredients = trim_ingredients.replaceAll(':', ','); //replace any semicolons with commas
    List<String> scannedIngredients = trim_ingredients.split(","); //split ingredients after comma and store in list
    final len = scannedIngredients.length;

    ReCase rc_name;
    await FirebaseFirestore.instance.collection("ingredients").get()
        .then((querySnapshot) {
      print("Successfully load all ingredients");
      querySnapshot.docs.forEach((element) {
        //format ingredients in database to compare
        rc_name = ReCase(element.data()['name']);
        String cc_name = rc_name.camelCase;
        String formatted_name = cc_name[0].toUpperCase() + cc_name.substring(1);//uppercase first character

        //find where ingredients in database == scanned ingredients and store in map
        for (var i = 0; i < len; i++) {
          if (formatted_name == scannedIngredients[i]) {
            //Add name as key and fields as value
             results[element.data()['name']] = [element.data()['description'],
             element.data()['color'], element.data()['label']];
            break;
          }
        }
      });
    }).catchError((error){
      print("Fail to load all ingredients");
      print(error);
    });

    print("Common ingredients found: ");
    print(results.keys);
    seperateByColorIngredients();  //filter ingredients by color
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});
        getRecognisedText(pickedImage);
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      scannedText = "Error occured while scanning";
      setState(() {});
    }
  }

  void getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textDetector();
    RecognisedText recognisedText = await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText = "";
    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        scannedText = scannedText + line.text + "\n";
      }
    }
    textScanning = false;
    setState(() {});
  }

  //sends filtered data to search page and resets counters
  void searchResultsPage(){
    //Map<String, List<String>> textToSend = results;
    setState((){
      Navigator.push( //change from one screen to another
        context,
        MaterialPageRoute(builder: (context) => MySearchResultsPage(title: 'Results',
            foundIngred: results, numOfgreenIngred: numOfGreenIngred,
            numOfredIngred: numOfRedIngred, numOfyellowIngred: numOfYellowIngred,
            scannedImage: Image.file(File(imageFile!.path)), imageUrl: pugImageUrl,
            isDarkModeEnabled: isDarkModeEnabled, grade: grade, gradeColor: gradeColor
          )
        ),
      ).then((value) => reset());
      print("Now on Results Page");//debug
    });
  }
  void loginPage(){
    setState((){
      Navigator.push( //change from one screen to another
        context,
        MaterialPageRoute(builder: (context) => const MyLoginPage(title: 'Login')),
      );
      print("Now on Login Page");//debug
    });
  }
  void databasePage(){
    setState((){
      Navigator.push( //change from one screen to another
        context,
        MaterialPageRoute(builder: (context) => const MyDatabasePage(title: 'Database')),
      );
      print("Now on Database Page");//debug
    });
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

  void calculateOverallRating(){
    double point = 100 / results.keys.length;  //each ingredient is worth this amount of points
    double overallRating = 0.0;  //calculate overall rating
    double bonus = 0.0; //bonus points for first 5 ingredients
    bool checkFirstFiveGreen = false;
    bool checkFirstFiveYellow = false;
    bool checkFirstFiveRed = false;

    for(var i = 0; i < results.keys.length; i++){
      if(results.values.elementAt(i).elementAt(1) == "yellow"){
        overallRating += (point/2); //half point
        //check once if yellow in first 5 ingredients subtract bonus point once
        if(i < 5 && checkFirstFiveYellow == false){
          bonus -= (point/2);
          checkFirstFiveYellow = true;
        }
      }
      if(results.values.elementAt(i).elementAt(1) == "red"){
        overallRating += 0.0; //no point
        //check once if red in first 5 ingredients subtract bonus point once
        if(i < 5 && checkFirstFiveRed == false){
          bonus -= (point);
          checkFirstFiveRed = true;
        }
      }
      if(results.values.elementAt(i).elementAt(1) == "green"){ //if name.color == green
        overallRating += point; //full point
        //check once if all green in first 5 ingredients then add bonus point once
        if(i == 4 && checkFirstFiveGreen == false && checkFirstFiveYellow != true
            && checkFirstFiveRed != true){
          bonus += point;
          checkFirstFiveGreen = true;
        }
      }
    }
    overallRating += bonus; //add bonus points to overall rating
    print("Rating");
    print(overallRating);


    if(overallRating >= 97.0){
      grade["A+"] = overallRating;
      uploadPugImage = "pug_happy";
      gradeColor = Colors.lightGreen;
    }
    else if(overallRating >= 93.0){
      grade["A"] = overallRating;
      uploadPugImage = "pug_happy";
      gradeColor = Colors.lightGreen;
    }
    else if(overallRating >= 90.0){
      grade["A-"] = overallRating;
      uploadPugImage = "pug_happy";
      gradeColor = Colors.lightGreen;
    }
    else if(overallRating >= 87.0){
      grade["B+"] = overallRating;
      uploadPugImage = "pug_happy";
      gradeColor = Colors.lightGreen;
    }
    else if(overallRating >= 83.0){
      grade["B"] = overallRating;
      uploadPugImage = "pug_happy";
      gradeColor = Colors.lightGreen;
    }
    else if(overallRating >= 80.0){
      grade["B-"] = overallRating;
      uploadPugImage = "pug_happy";
      gradeColor = Colors.lightGreen;
    }
    else if(overallRating >= 77.0){
      grade["C+"] = overallRating;
      uploadPugImage = "pug_tilted";
      gradeColor = Colors.amber;
    }
    else if(overallRating >= 73.0){
      grade["C"] = overallRating;
      uploadPugImage = "pug_tilted";
      gradeColor = Colors.amber;
    }
    else if(overallRating >= 70.0){
      grade["C-"] = overallRating;
      uploadPugImage = "pug_tilted";
      gradeColor = Colors.amber;
    }
    else if(overallRating >= 67.0){
      grade["D+"] = overallRating;
      uploadPugImage = "pug_sad";
      gradeColor = Colors.red;
    }
    else if(overallRating >= 63.0){
      grade["D"] = overallRating;
      uploadPugImage = "pug_sad";
      gradeColor = Colors.red;
    }
    else if(overallRating >= 60.0){
      grade["D-"] = overallRating;
      uploadPugImage = "pug_sad";
      gradeColor = Colors.red;
    }
    else{
      grade["F"] = overallRating;
      uploadPugImage = "pug_sad";
      gradeColor = Colors.red;
    }
    print(grade);
  }


   loadPugImage() async {
    dynamic image = await FirebaseDatabase.instance.ref().child(uploadPugImage).once()
        .then((datasnapshot) {
      print("Sucessfully loaded the pug image");
      print(datasnapshot.snapshot.value);
      return pugImageUrl = datasnapshot.snapshot.value;
    }).catchError((error){
      print("Failed to load the pug image!");
      print(error);
    });
  }


   loadIngredientListImage() async {
    final image = await FirebaseDatabase.instance.ref().child("ingredient_list_example").once()
        .then((datasnapshot) {
      print("Sucessfully loaded the ingredient list example image");
      print(datasnapshot.snapshot.value);
      ingredientImageUrl =  datasnapshot.snapshot.value;
    }).catchError((error){
      print("Failed to load  the ingredient list example image!");
      print(error);
    });
  }
}

    // entire UI
    // return FutureBuilder(
    //     future: myFuture,
    //     builder: (context, snapshot) { //display once done scanning
    //       if (snapshot.connectionState == ConnectionState.done) {
    //         return Scaffold( //default UI
    //             appBar: AppBar(
    //               // Here we take the value from the MyHomePage object that was created by
    //               // the App.build method, and use it to set our appbar title.
    //               title: Text("Barcode Scan-" + widget.title),
    //             ),
    //
    //             body: Center(
    //               // Center is a layout widget. It takes a single child and positions it
    //               // in the middle of the parent.
    //                 child: Column(
    //                     mainAxisAlignment: MainAxisAlignment.center, //alignment
    //                     children: <Widget>[ //list of widgets
    //                       Text(
    //                           'Scan result : $_scanBarcode\n',
    //                           style: TextStyle(fontSize: 20)
    //                       ),
    //                       ElevatedButton(
    //                         onPressed: () => scanBarcodeNormal(),
    //                         child: Text(
    //                           'Try again ',
    //                        )
    //                       ),
    //                       ElevatedButton(
    //                           onPressed: () => loginPage(),
    //                           child: Text(
    //                             'login_page',
    //                           )
    //                       ),
    //                       ElevatedButton(
    //                           onPressed: () => databasePage(),
    //                           child: Text(
    //                             'data_base',
    //                           )
    //                       ),
    //
    //                     ]
    //                 )
    //
    //             )
    //         );
    //       }
    //       else { //when loading
    //         return CircularProgressIndicator();
    //       }
    //     }
    // );


// class Ingredient {
//   final String name;
//   final String role;
//
//   const Ingredient({
//     required this.name,
//     required this.role,
//   });
//
//   factory Ingredient.fromJson(Map<String, dynamic> json) {
//     return Ingredient(
//       name: json['name'] as String,
//       role: json['role'] as String,
//     );
//   }
// //         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,  //alignment
//           children: <Widget>[ //list of widgets
//             // Image(
//             //     //image: NetworkImage('https://theme.zdassets.com/theme_assets/737642/a47e9e5d60e7dff1e55111cf0caa737d9621da6c.png')
//             //   image: AssetImage('assets/appLogo.png'),
//             // ),
//             // ElevatedButton(
//             //     onPressed: () => scanBarcodeNormal(),
//             //     child: Text('Start barcode scan')),
//
//             Text(
//                 'Scan result : $_scanBarcode\n',
//                 style: TextStyle(fontSize: 20)
//             ),
//            ElevatedButton(
//                onPressed: () => scanBarcodeNormal(),
//                child: Text(
//                  'Try again ',
//                )
//            ),
//
//             // const Text(
//             //   'This is another text - Screen No.1',
//             //   style: const TextStyle(
//             //       fontSize: 20,
//             //       fontWeight: FontWeight.bold,
//             //       fontStyle: FontStyle.italic,
//             //       backgroundColor: Colors.amber
//             //   ),
//             // ),
//
//             // const TextField(
//             //   obscureText: false,
//             //   decoration: InputDecoration(
//             //     border: OutlineInputBorder(),
//             //     labelText: 'Username',
//             //   ),
//             // ),
//
//             // const Text(
//             //     'App Logo - Screen No.1'),
//             // const Text(
//             //   'You have clicked the button this many times:',
//             // ),
//             // Text(
//             //   '${_counter * 2}',  //$ to convert to string
//             //   style: Theme.of(context).textTheme.headline4, //style of text
//             // ),
//
//             // ElevatedButton(
//             //   onPressed: (){
//             //     _incrementCounter();
//             //   },
//             //  child: Text(
//             //    'Confirm',
//             //    style: TextStyle(
//             //      color: Colors.blue,
//             //    ),
//             //  ),
//             // )
//           ],
//         ),
//       ),
//
//     );
//

