import 'package:flutter/material.dart';
import 'package:happy_pug/data_base.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:happy_pug/search_results.dart';
import 'firebase_options.dart';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const MyHomePage(title: 'Results'),
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
  XFile? imageFile;
  String scannedText = "";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getIngredients(),
        builder:(context, snapshot){
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text("Text Recognition example"),
            ),
            body: Center(
                child: SingleChildScrollView(
                  child: Container(
                      margin: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () => searchResultsPage(),
                              child: Text(
                                'search_page',
                              )
                          ),

                          ElevatedButton(
                              onPressed: () => loginPage(),
                              child: Text(
                                'login_page',
                              )
                          ),
                          ElevatedButton(
                              onPressed: () => databasePage(),
                              child: Text(
                                'data_base',
                              )
                          ),
                          if (textScanning) const CircularProgressIndicator(),
                          if (!textScanning && imageFile == null)
                            Container(  //Picture container
                              width: 300,
                              height: 300,
                              color: Colors.grey[300]!,
                            ),
                          if (imageFile != null) Image.file(File(imageFile!.path)),
                          Row(  //UI
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(  //Gallery button
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  padding: const EdgeInsets.only(top: 10),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.white,
                                      onPrimary: Colors.grey,
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
                                                fontSize: 13, color: Colors.grey[600]),
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                              Container(  //Camera button
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  padding: const EdgeInsets.only(top: 10),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.white,
                                      onPrimary: Colors.grey,
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
                                                fontSize: 13, color: Colors.grey[600]),
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // Container(  //display results
                          //   child: Text(
                          //     scannedText,
                          //     style: TextStyle(fontSize: 20),
                          //   ),
                          // )
                        ],
                      )),
                )),
          );

      }
    );

  }

  Future<void> _getIngredients() async {
    String trim_ingredients = scannedText.replaceAll(new RegExp(r"\s+"), ""); //delete all white space
    List<String> split = trim_ingredients.split(",");
    final len = split.length;

    print(split);
    for(var i =0; i <len; i++){
      if(split[i] == "Salt"){
        print("FOUND");
        return;
      }
    }
    print("hi");

    // print("Size of ingredient list: $len");
    // print(split[10]);
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

  void searchResultsPage(){
    setState((){
      Navigator.push( //change from one screen to another
        context,
        MaterialPageRoute(builder: (context) => const MySearchResultsPage(title: 'search_results')),
      );
      print("Now on Search Results Page");//debug
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

  @override
  void initState() {
    super.initState();
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
