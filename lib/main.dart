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
  Map<String, dynamic> filtered_ingredients = {};
  Map<String, List<String>> results = {};
  String greenIngred = "";
  String redIngred = "";
  String yellowIngred = "";
  int numOfGreenIngred = 0;
  int numOfRedIngred = 0;
  int numOfYellowIngred = 0;
  bool onClick = false;
  var imageUrl = null;

  @override
  void initState() {
    super.initState();
    loadImage();//load image from real time database
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
          title: const Text("Happy Pug", textAlign: TextAlign.left),
          actions: [  
            Transform.scale(
              scale: 0.8,
              child: DayNightSwitcher(
                isDarkModeEnabled: isDarkModeEnabled,
                onStateChanged: onStateChanged,
                dayBackgroundColor: Colors.white24,

              ),
            )

            // Padding(
            //   padding: EdgeInsets.only(top: 10),
            //   child: Text('Dark mode is ' +
            //       (isDarkModeEnabled ? 'enabled' : 'disabled') +
            //       '.'),
            // ),
          ],
        ),
        body: Center(
            child: SingleChildScrollView(
              child: Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      if (!textScanning && imageFile == null)
                        Container(  //Template container
                          width: 300,
                          height: 300,
                          color: Colors.grey[300]!,
                        ),

                      if (imageFile != null)
                      Stack( //display scanned image //PROBLEM
                        alignment: Alignment.center,
                        children: [
                          Image.file(File(imageFile!.path)),

                          if (textScanning) Center(
                            child: CircularProgressIndicator(),
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
                                //  primary: Colors.white,
                                 // onPrimary: Colors.grey,
                                  shadowColor: Colors.grey[400],
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),
                                ),
                                onPressed: () {
                                  getImage(ImageSource.gallery);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 5),
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
                                            fontSize: 13 * textScale,
                                            //color: Colors.grey[600]
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
                                  //primary: Colors.white,
                                  //onPrimary: Colors.grey,
                                  shadowColor: Colors.grey[400],
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),
                                ),
                                onPressed: () {
                                  getImage(ImageSource.camera);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 5),
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
                                            fontSize: 13 * textScale,
                                            //color: Colors.grey[600]
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
                                child:  ElevatedButton(
                                    onPressed: (){
                                      if(onClick == false){ //user can press btn only once
                                        _filterIngredients();
                                      }
                                      onClick = true;
                                    },
                                    //onPressed: () => _filterIngredients(),
                                    child: Text(
                                      'search_results',
                                    )
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
    setState((){});
  }
  void getGreenIngredients(){
    for(var i = 0; i < results.keys.length; i++){
      if(results.values.elementAt(i).elementAt(1) == "green"){//if name.color == green
        greenIngred = results.values.elementAt(i).elementAt(1);
        numOfGreenIngred++;
        print(results.keys.elementAt(i) + " is " + results.values.elementAt(i).elementAt(1));
      }
    }

  }
  void getRedIngredients(){
    for(var i = 0; i < results.keys.length; i++){
      if(results.values.elementAt(i).elementAt(1) == "red"){//if name.color == red
        redIngred =  results.values.elementAt(i).elementAt(1);
        numOfRedIngred++;
        print(results.keys.elementAt(i) + " is " + results.values.elementAt(i).elementAt(1));
      }
    }
  }
  void getYellowIngredients(){
    for(var i = 0; i < results.keys.length; i++){
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
    getGreenIngredients();  //fliter ingredients by color
    getRedIngredients();
    getYellowIngredients();
    searchResultsPage();  //go to result page once finished filtering
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
            scannedImage: Image.file(File(imageFile!.path)), imageUrl: imageUrl )
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
  loadImage() async {
    FirebaseDatabase.instance.ref().child("happy_pug_image").once()
        .then((datasnapshot) {
      print("Sucessfully loaded the image");
      print(datasnapshot.snapshot.value);
      imageUrl = datasnapshot.snapshot.value;
    }).catchError((error){
      print("Failed to load the image!");
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

