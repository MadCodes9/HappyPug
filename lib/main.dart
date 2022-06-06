import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:happy_pug/data_base.dart';
import 'package:html/parser.dart';
import 'package:web_scraper/web_scraper.dart';
import 'next_page.dart';
import 'another_page.dart';
import 'login_page.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


//void main() => runApp(MyApp()); //lambda expression same as below format
// void main() {
//
//   runApp(const MyApp());
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget { //global data, style of entire app
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',  //name of app
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.purple,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),  //home screen

    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({Key? key, required this.title}) : super(key: key);//constructor

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title; //attribute

  @override
  State<MyHomePage> createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {
  //home screen actions
  String _scanBarcode = 'Unknown';
  late final Future? myFuture;



  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
        '#33fff3', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) => print('BC' + barcode));
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#33fff3', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    }
    on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    setState(() {
      _scanBarcode = barcodeScanRes;
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


  // Future<List<Ingredient>> _getIngredients() async{
  //   var data =
  //       await http.get("https://tailblazerspets.com/tailblazers-pet-ingredient-dictionary.php");
  //   var jsonData = jsonDecode(data.body);
  //   List<Ingredient> ingredients = [];
  //
  //   for(var ingredient in jsonData["result"]){
  //     Ingredient newIngredient = Ingredient(ingredient["name"], ingredient["value"]);
  //     ingredients.add(newIngredient);
  //   }
  //   print(ingredients);
  //   return ingredients;
  // }

  // // initialize WebScraper by passing base url of website
  // final webScraper = WebScraper('https://webscraper.io');
  //
  // // Response of getElement is always List<Map<String, dynamic>>
  // List<Map<String, dynamic>>? productNames;
  // late List<Map<String, dynamic>> productDescriptions;
  //
  // void fetchProducts() async {
  //   // Loads web page and downloads into local state of library
  //   if (await webScraper
  //       .loadWebPage('/test-sites/e-commerce/allinone/computers/laptops')) {
  //     setState(() {
  //       // getElement takes the address of html tag/element and attributes you want to scrap from website
  //       // it will return the attributes in the same order passed
  //       productNames = webScraper.getElement(
  //           'div.thumbnail > div.caption > h4 > a.title', ['href', 'title']);
  //       productDescriptions = webScraper.getElement(
  //           'div.thumbnail > div.caption > p.description', ['class']);
  //     });
  //   }
  //   print((productDescriptions));
  // }


//   Future<List<String>> _getIngredients() async {
// //Getting the response from the targeted url
//     final response =
//     await http.Client().get(Uri.parse('https://tailblazerspets.com/tailblazers-pet-ingredient-dictionary.php'));
//     //Status Code 200 means response has been received successfully
//     if (response.statusCode == 200) {
//       //Getting the html document from the response
//       var document = parser.parse(response.body);
//       try {
//         //Scraping the first article title
//         var responseString1 = document
//             .getElementsByClassName('row flex-container')[0]
//             .children[0]
//             .children[0];
//         print(responseString1.text.trim());
//
//
//
//
//         //Converting the extracted titles into string and returning a list of Strings
//         return [
//           responseString1.text.trim()
//         ];
//       } catch (e) {
//         return ['', '', 'ERROR!'];
//       }
//     } else {
//       return ['', '', 'ERROR: ${response.statusCode}.'];
//     }
//   }

  // Future _getIngredients() async{ //get data on web
  //   // final url =
  //   //   Uri.parse('https://tailblazerspets.com/tailblazers-pet-ingredient-dictionary.php');
  //   // final response = await http.get(url);
  //   // dom.Document html = dom.Document.html(response.body);
  //   //
  //   // final ingredients= html
  //   //   .querySelectorAll('button.btn-3d:nth-child(1)')
  //   //    .map((element) => element.innerHtml.trim()).toList();
  //   //
  //   // print('Count: ${ingredients.length}');
  //   // for (final ingredient in ingredients){
  //   //   debugPrint(ingredient);
  //   // }
  //   //
  //   // setState((){
  //   //   ingredientlist = List.generate(
  //   //       ingredients.length
  //   //       , (index) => Ingredient(
  //   //           name,
  //   //           color,
  //   //           url
  //   //         ),
  //   //       );
  //   // });
  //
  //
  // }

  @override
  void initState() {
    super.initState();
    myFuture = scanBarcodeNormal();
   // _getIngredients();
  }

  @override
  Widget build(BuildContext context) {
    //entire UI
    return FutureBuilder(
        future: myFuture, //display
        builder: (context, snapshot) { //display once done scanning
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold( //default UI
                appBar: AppBar(
                  // Here we take the value from the MyHomePage object that was created by
                  // the App.build method, and use it to set our appbar title.
                  title: Text("Barcode Scan-" + widget.title),
                ),

                body: Center(
                  // Center is a layout widget. It takes a single child and positions it
                  // in the middle of the parent.
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, //alignment
                        children: <Widget>[ //list of widgets
                          Text(
                              'Scan result : $_scanBarcode\n',
                              style: TextStyle(fontSize: 20)
                          ),
                          ElevatedButton(
                            onPressed: () => scanBarcodeNormal(),
                            child: Text(
                              'Try again ',
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

                        ]
                    )

                )
            );
          }
          else { //when loading
            return CircularProgressIndicator();
          }
        }
    );
  }
}

class Ingredient {
  final String name;
  final String role;

  const Ingredient({
    required this.name,
    required this.role,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      role: json['role'] as String,
    );
  }
//         child: Column(
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
}
