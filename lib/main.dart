import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:happy_pug/data_base.dart';
import 'package:html/parser.dart';
import 'package:web_scraper/web_scraper.dart';
import 'login_page.dart';
import 'search_results.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:learning_input_image/learning_input_image.dart';
import 'package:learning_text_recognition/learning_text_recognition.dart';
import 'package:provider/provider.dart';

//void main() => runApp(MyApp()); //lambda expression same as below format
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget { //global data, style of entire app
  // const MyApp({super.key});
  //
  // @override
  // Widget build(BuildContext context) {
  //    ChangeNotifierProvider(
  //     create: (_) => TextRecognitionState(),
  //      child: Scaffold(
  //
  //      ),
  //   );
  //   return MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     title: 'Welcome to Flutter',
  //     home: Scaffold(
  //       appBar: AppBar(
  //         title: const Text('Home'),
  //       ),
  //       body: const Center(
  //         child: Text('This is a home page'),
  //       ),
  //
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryTextTheme: TextTheme(
          headline6: TextStyle(color: Colors.white),
        ),

      ),
       home: ChangeNotifierProvider(
         create: (_) => TextRecognitionState(),
         child: TextRecognitionPage(title: "HI"),  //layout of text_recongnition
       )
        //Scaffold(
      //     body: ChangeNotifierProvider(
      //       create: (_) => TextRecognitionState(),
      //       child: TextRecognitionPage(title: "HI"),  //layout of text_recongnition
      //     )
      // ),

    );
  }
}

class TextRecognitionPage extends StatefulWidget {

  const TextRecognitionPage({Key? key, required this.title}) : super(key: key);//constructor
  final String title; //attribute
  @override
  State<TextRecognitionPage> createState() => _TextRecognitionPageState();

}

class  _TextRecognitionPageState  extends State<TextRecognitionPage> {
  //home screen actions
  String _scanBarcode = 'Unknown';
  //late final Future? myFuture;
  String ingredients = "";

  TextRecognition? _textRecognition = TextRecognition(
    options: TextRecognitionOptions.Default,
  );

  Future<void> _startRecognition(InputImage image) async {
    TextRecognitionState state = Provider.of(context, listen: false);

    if (state.isNotProcessing) {
      state.startProcessing();
      state.image = image;
      state.data = await _textRecognition?.process(image);
      state.stopProcessing();
    }
    ingredients = state.text;  //assign text into a String called ingredients
  }

  @override
  void dispose() {
    _textRecognition?.dispose();
    super.dispose();
  }

  Future<void> _getIngredients() async {
    String trim_ingredients = ingredients.replaceAll(new RegExp(r"\s+"), ""); //delete all white space
    List<String> split = trim_ingredients.split(",");
    final len = split.length;

    print(split);
    for(var i =0; i <len; i++){
      if(split[i] == "L-Carnitine"){
        print("FOUND");
        return;
      }
    }
  print("hi");

   // print("Size of ingredient list: $len");
  // print(split[10]);
  }

  // Future<void> startBarcodeScanStream() async {
  //   FlutterBarcodeScanner.getBarcodeStreamReceiver(
  //       '#33fff3', 'Cancel', true, ScanMode.BARCODE)!
  //       .listen((barcode) => print('BarCode:' + barcode));
  // }
  //
  // // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> scanBarcodeNormal() async {
  //   String barcodeScanRes;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
  //         '#33fff3', 'Cancel', true, ScanMode.BARCODE);
  //     print(barcodeScanRes);
  //   }
  //   on PlatformException {
  //     barcodeScanRes = 'Failed to get platform version.';
  //   }
  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;
  //   setState(() {
  //     _scanBarcode = barcodeScanRes;
  //   });
  // }
 void loginPage(){
    setState((){
      Navigator.push( //change from one screen to another
        context,
        MaterialPageRoute(builder: (context) => const MySearchResultsPage(title: 'Login')),
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


  //
  // @override
  // void initState() {
  //   super.initState();
  // // TextRecognitionPage(title: "TEST",);
  //  //  ChangeNotifierProvider(
  //  //      create: (_) => TextRecognitionState(),
  //  //  );
  //  // myFuture = scanBarcodeNormal();
  //  // _getIngredients();
  // }

  @override
  Widget build(BuildContext context) {
    return InputCameraView(
          mode: InputCameraMode.gallery,
          //resolutionPreset: ResolutionPreset.high,
           title: '',
          onImage: _startRecognition,
          overlay: Consumer<TextRecognitionState>(
            builder: (_, state, __) {
              if (state.isNotEmpty) {
                return Center(
                    child: FutureBuilder(
                        future: _getIngredients(),  //debug
                        builder: (context, snapshot){
                          if (state._isProcessing == false) { //Data is done processing
                            return Scaffold(      //default UI
                                body: Center(
                                  // Center is a layout widget. It takes a single child and positions it
                                  // in the middle of the parent.
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center, //alignment
                                        children: <Widget>[
                                          //list of widgets
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

                                        ]
                                    )

                                )
                            );
                          }
                          else{
                            return CircularProgressIndicator();
                          }

                        }
                    )

                );
              }
              return Center();
            },
          ),
    );

    // child: Container(
    //   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    //   decoration: BoxDecoration(
    //     color: Colors.white.withOpacity(0.8),
    //     borderRadius: BorderRadius.all(Radius.circular(4.0)),
    //   ),
    //   child: Text("Finished Scanning!"),
    //   // child: Text(  //output ingredient to screen
    //   //   state.text, //ingredients
    //   //   style: TextStyle(
    //   //     fontWeight: FontWeight.w500,
    //   //   ),
    //   //
    //   // ),
    // ),

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
  }
}

class TextRecognitionState extends ChangeNotifier {
  InputImage? _image;
  RecognizedText? _data;
  bool _isProcessing = false;

  InputImage? get image => _image;
  RecognizedText? get data => _data;
  String get text => _data!.text;
  bool get isNotProcessing => !_isProcessing;
  bool get isNotEmpty => _data != null && text.isNotEmpty;

  void startProcessing() {
    _isProcessing = true;
    notifyListeners();
  }

  void stopProcessing() {
    _isProcessing = false;
    notifyListeners();
  }

  set image(InputImage? image) {
    _image = image;
    notifyListeners();
  }

  set data(RecognizedText? data) {
    _data = data;
    notifyListeners();
  }
}



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

