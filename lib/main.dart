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
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:string_extensions/string_extensions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:emojis/emojis.dart';
import 'package:auto_size_text/auto_size_text.dart';

//void main() => runApp(MyApp()); //lambda expression same as below format
void main() async {
  DecorationImage(
    image: AssetImage("/media/madri/New Volume/CSCI/CS4750/happy_pug/android/assets/images/splash_background.png"),
      fit: BoxFit.fill,
  );

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await execute(InternetConnectionChecker());
  // Create customized instance which can be registered via dependency injection
  final InternetConnectionChecker customInstance =
  InternetConnectionChecker.createInstance(
    checkTimeout: const Duration(seconds: 1),
    checkInterval: const Duration(seconds: 1),
  );
  // Check internet connection with created instance
  await execute(customInstance);
}

Future<void> execute(
    InternetConnectionChecker internetConnectionChecker,
    ) async {
  // Simple check to see if we have Internet
  print('''The statement 'this machine is connected to the Internet' is: ''');
  final bool isConnected = await InternetConnectionChecker().hasConnection;
  print(isConnected.toString(),);
  print('Current status: ${await InternetConnectionChecker().connectionStatus}',);

  // actively listen for status updates
  final StreamSubscription<InternetConnectionStatus> listener =
  InternetConnectionChecker().onStatusChange.listen(
        (InternetConnectionStatus status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          print('Data connection is available.');
          break;
        case InternetConnectionStatus.disconnected:
          print('You are disconnected from the internet.');
          break;
      }
    },
  );
  runApp(MyApp());
}

Future initialization(BuildContext? context) async{
  //Delay to show splash screen and load resources
  await Future.delayed(Duration(seconds: 3));
}

class MyApp extends StatelessWidget { //global data, style of entire app
  MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Home', isDarkModeEnabled: false,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.isDarkModeEnabled}) : super(key: key);//constructor
  String title; //attribute
  bool isDarkModeEnabled;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  bool textScanning = false;
  bool filteringResults = false;
  bool onClickResults = false;
  bool timerTriggered = false;
  XFile? imageFile;
  Map<String, List<String>> results = {};
  Map<String, double> pieChartData = {};
  Map<String, double> grade = {};
  String scannedText = "";
  String greenIngred = "";
  String redIngred = "";
  String yellowIngred = "";
  String uploadPugImage = "";
  int numOfGreenIngred = 0;
  int numOfRedIngred = 0;
  int numOfYellowIngred = 0;
  Color gradeColor = Colors.transparent;
  var pugImageUrl;
  var ingredientImageUrl;
  final ScrollController _scrollController = ScrollController();

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
      themeMode: widget.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            "Happy Pug",
            textAlign: TextAlign.left,
            style: GoogleFonts.pacifico(fontSize: 20, fontWeight: FontWeight.w500),
            maxLines: 1,
            minFontSize: 12,
            //stepGranularity: 5.0, //decreases by 5 when text doesn't fit
            presetFontSizes: [20, 18, 14],
            overflow: TextOverflow.ellipsis,
            //wrapWords: false, //this wont break up words to next line, just shrink text to fit
          ),
          actions: [
            Transform.scale(
              scale: 0.7,
              child: DayNightSwitcher(
                isDarkModeEnabled: widget.isDarkModeEnabled,
                onStateChanged: onStateChanged,
                dayBackgroundColor: Colors.white24,
              ),
            ),
          ],
        ),
        body: Center(
            widthFactor:  MediaQuery.of(context).size.width,
            heightFactor: MediaQuery.of(context).size.height,
            child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                color:  Colors.deepPurple,
                child: Scrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:[
                        if(!textScanning && imageFile == null)
                          AutoSizeText(
                              "Scan Ingredients",
                              maxLines: 1,
                              presetFontSizes: [18, 15, 14],
                              minFontSize: 12,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
                          ),
                        if(!textScanning && imageFile == null)
                          Padding(
                            padding: EdgeInsets.only(left: 5,right: 5,top: 6, bottom: 20),
                            child: AutoSizeText(
                                "Focus camera on the ingredient list of your dog food product like below",
                                maxLines: 2,
                                presetFontSizes: [15, 14, 12],
                                minFontSize: 12,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: Colors.blueGrey[600])),
                          ),

                        if (!textScanning && imageFile == null)
                          Container(  //Template container
                            margin: EdgeInsets.only(bottom: 20),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.6,
                            color: Colors.grey[300]!,
                            child: FutureBuilder(
                                future: loadIngredientListImage(),
                                builder: (context, snapshot){
                                  if(snapshot.connectionState == ConnectionState.done){
                                    return Image.network(ingredientImageUrl, fit: BoxFit.fill,);
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(10),
                                child:
                                AutoSizeText(
                                    "Captured Image",
                                    maxLines: 1,
                                    presetFontSizes: [18, 15, 14],
                                    minFontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
                                ),
                              ),
                              Stack( //display scanned image
                                alignment: Alignment.center,
                                children: [
                                  //set a max height so if picture is in portrait mode, than doesn't take entire screen
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
                                    child:  Container(
                                      margin: EdgeInsets.only(bottom: 20),
                                      width: MediaQuery.of(context).size.width,
                                      child: Image.file(File(imageFile!.path)),
                                    ),
                                  ),
                                  if(textScanning)
                                    ConstrainedBox(
                                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.width * 0.6),
                                      child:  Column(
                                        children: [
                                          AutoSizeText(
                                              "Processing...",
                                              maxLines: 1,
                                              presetFontSizes: [18, 15, 14],
                                              minFontSize: 12,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                          Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ],
                                      ),
                                    ),

                                  if(filteringResults)
                                    ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                                      child: Column(
                                        children: [
                                          AutoSizeText(
                                            "Filtering Ingredients...",
                                            maxLines: 1,
                                            presetFontSizes: [18, 15, 14],
                                            minFontSize: 12,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                          Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          if(timerTriggered)
                                            Padding(
                                              padding: EdgeInsets.only(top: 60),
                                              child: AutoSizeText(
                                                "Almost done, Please wait...${Emojis.dogFace}",
                                                maxLines: 2,
                                                presetFontSizes: [18, 15, 14],
                                                minFontSize: 12,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),

                        Row(  //UI
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(//Gallery button
                                height: MediaQuery.of(context).size.height * 0.1,
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                    elevation: 10,
                                    primary: widget.isDarkModeEnabled ?Color(0xFF253341):Colors.deepPurple[400],
                                    shadowColor: widget.isDarkModeEnabled ?Color(0xFF253341).withOpacity(0.5):Color(0xFFBDBDBD).withOpacity(0.5),
                                  ),
                                  onPressed: () {
                                    //check permissions to gallery
                                    checkPermissionStatus(ImageSource.gallery, textScale);
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        color: Color(0xFFFAFAFA),
                                        Icons.image,
                                        size: 30,
                                      ),
                                      AutoSizeText(
                                        "Gallery",
                                        maxLines: 1,
                                        minFontSize: 12,
                                        stepGranularity: 2.0,
                                        wrapWords: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFFFAFAFA),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Expanded(
                              child: Container(  //Camera button
                                  height: MediaQuery.of(context).size.height * 0.1,
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  alignment: Alignment.centerLeft,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                      elevation: 10,
                                      primary: widget.isDarkModeEnabled ?Color(0xFF253341):Colors.deepPurple[400],
                                      shadowColor: widget.isDarkModeEnabled ?Color(0xFF253341).withOpacity(0.5):Color(0xFFBDBDBD).withOpacity(0.5),
                                    ),
                                    onPressed: () {
                                      //check permissions to camera
                                      checkPermissionStatus(ImageSource.camera, textScale);
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          color: Color(0xFFFAFAFA),
                                          Icons.camera_alt,
                                          size: 30,
                                        ),
                                        AutoSizeText(
                                          "Camera",
                                          maxLines: 1,
                                          minFontSize: 12,
                                          stepGranularity: 2.0,
                                          wrapWords: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFFFAFAFA),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                              ),
                            ),


                          ],
                        ),

                        //once loading is done display buttons and results are not empty
                        if(textScanning == false && imageFile != null)
                          Column(
                              children:<Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 15),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                                        elevation: 10,
                                        primary: widget.isDarkModeEnabled ?Color(0xFF253341):Colors.deepPurple[400],
                                        shadowColor:  widget.isDarkModeEnabled ?Color(0xFF253341).withOpacity(0.5):Color(0xFFBDBDBD).withOpacity(0.5),
                                      ),
                                      onPressed: () {
                                        setState((){
                                          filteringResults = true;
                                        });

                                        if(onClickResults == false){  //user can press btn only once
                                          //filter ingredients then calculate the ingredient rating
                                          // then load image from real time database and than go to result page
                                          _filterIngredients().then((value) => calculateOverallRating()).
                                          then((value) => loadPugImage()).then((value) => searchResultsPage(textScale));
                                        }
                                        onClickResults = true;
                                      },
                                      child: AutoSizeText(
                                          'View Results',
                                          maxLines: 1,
                                          minFontSize: 12,
                                          stepGranularity: 2.0,
                                          wrapWords: false,
                                          style: TextStyle(fontSize: 14, color: Color(0xFFFAFAFA))
                                      )
                                  ),
                                ),
                              ]
                          ),

                        //
                        // ElevatedButton(
                        //     onPressed: (){
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(builder: (context) => MyDatabasePage(title: "Home Page")),
                        //       );
                        //     },
                        //     child:  Text(
                        //         'Database',
                        //         style: TextStyle(
                        //           fontSize: 14 * textScale,
                        //           color: Color(0xFFFAFAFA),
                        //         )
                        //     )
                        // )
                      ],
                    ),
                  )
                )



            ),
        ),
      ),
    );
  }

  FutureOr reset(){ //reset all counters
    numOfGreenIngred = 0;
    numOfRedIngred = 0;
    numOfYellowIngred = 0;
    onClickResults = false;
    filteringResults = false;
    timerTriggered = false;
    grade = {};

    setState((){});
  }

  void checkPermissionStatus(ImageSource source, double textScale) async {
    var cameraStatus = await Permission.camera.status;
    print(cameraStatus);

    if(!cameraStatus.isGranted){  //if camera is not granted, than request permission use
      await Permission.camera.request();
    }
    if(await Permission.camera.isGranted){ //if camera is granted, than call function to open camera
      getImage(source);
    } else{ //camera is not granted, so open settings
      print("No permission");
      showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              buttonPadding: EdgeInsets.all(0.8),
              backgroundColor: widget.isDarkModeEnabled ?Colors.blueGrey[900]: Colors.white,
              title: AutoSizeText(
                  "'Happy Pug' would like to access your camera",
                  maxLines: 1,
                  presetFontSizes: [18, 15, 14],
                  minFontSize: 12,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Container(
                      child: RichText(
                          text: TextSpan(
                            children:[
                              WidgetSpan(
                                  child: Padding(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Icon(
                                        Icons.camera,
                                        color: Colors.blueAccent,
                                        size: 20,
                                      ),
                                  )
                              ),
                              TextSpan(
                                text: "This app needs access to your camera and gallery to take pictures of the ingredient labels.",
                                style: TextStyle(fontSize: 15  * textScale, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                              )
                            ],
                          )
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: AutoSizeText(
                          "Apps->Happy Pug->Permissions->Camera to grant access",
                          maxLines: 1,
                          presetFontSizes: [15, 14, 12],
                          minFontSize: 12,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
                      ),
                    ),

                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[50],
                      side: BorderSide(color: Colors.grey, width: 0.8),
                    ),
                    child: AutoSizeText(
                        "Cancel",
                        maxLines: 1,
                        presetFontSizes: [15, 14, 12],
                        minFontSize: 12,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, color: Colors.blueGrey[900])
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage(title: "Home Page", isDarkModeEnabled: widget.isDarkModeEnabled,)),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: AutoSizeText(
                        "Open App Settings",
                        maxLines: 1,
                        presetFontSizes: [15, 14, 12],
                        minFontSize: 12,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, color: Colors.white)
                    ),
                    onPressed:  () => openAppSettings(),

                  )
                )
              ],
            );
          }
      );
    }
  }


  void seperateByColorIngredients(){
    for(var i = 0; i < results.keys.length; i++){
      if(results.values.elementAt(i).elementAt(1) == "green"){//if name.color == green
        greenIngred = results.values.elementAt(i).elementAt(1);
        numOfGreenIngred++;
      }
      if(results.values.elementAt(i).elementAt(1) == "red"){//if name.color == red
        redIngred =  results.values.elementAt(i).elementAt(1);
        numOfRedIngred++;
      }
      if(results.values.elementAt(i).elementAt(1) == "yellow"){//if name.color == yellow
        yellowIngred = results.values.elementAt(i).elementAt(1);
        numOfYellowIngred++;
      }
    }

  }

  Future _filterIngredients() async {
    //String manipulation to format scanned ingredients the same as database ingredients-lowercaseName
    String trim_ingredients = scannedText.replaceAll(':', ','); //replace any colons with a comma
    trim_ingredients = trim_ingredients.replaceAll('Ingredients', ','); //replace 'Ingredients' with a comma
    trim_ingredients = trim_ingredients.replaceAll('INGREDIENTS', ',');  //replace 'Ingredients' with a comma
    trim_ingredients = trim_ingredients.replaceAll('Vitamins', ''); //replace 'Ingredients' with a comma
    trim_ingredients = trim_ingredients.replaceAll('VITAMINS', '');  //replace 'Ingredients' with a comma
    trim_ingredients = trim_ingredients.replaceAll('Minerals', ''); //replace 'Ingredients' with a comma
    trim_ingredients = trim_ingredients.replaceAll('MINERALS', '');  //replace 'Ingredients' with a comma
    trim_ingredients = trim_ingredients.replaceAll(';', ','); //replace ';' with a comma
    trim_ingredients = trim_ingredients.replaceAll('.', ','); //replace period with a comma
    trim_ingredients = trim_ingredients.replaceAll('[', '');
    trim_ingredients = trim_ingredients.replaceAll(']', '');
    trim_ingredients = trim_ingredients.replaceAll("-", ""); //replace  '-' with a space
    trim_ingredients = trim_ingredients.replaceAll('(', ','); //replace '(' and ')' with commas to get actual ingredient name
    trim_ingredients = trim_ingredients.replaceAll(')', ',');
    trim_ingredients = trim_ingredients.replaceAll(new RegExp(r"\s+"), "").toLowerCase(); //eliminate all spaces and lowercase
    List<String> scannedIngredients = trim_ingredients.split(","); //split ingredients after comma and store in list

    // trim_ingredients = trim_ingredients.replaceAll(new RegExp(r"\([^)]*\)|()"), ""); //remove everything inside parenthesis
    final len = scannedIngredients.length;
    print("Scanned Ingredient Formatted");
    print(scannedIngredients);

    //search for ingredients in database
    for(var i = 0; i < len; i++){
      if(i > len/2){  //timer is triggered when filtering is half-way finished
        setState((){
          timerTriggered = true;
        });
      }
      await _findResults(scannedIngredients[i]);
    }
    print("Finished Filtering");
    print("Common ingredients found: ");
    print(results.keys);
    seperateByColorIngredients();  //filter ingredients by color
    setPieChartData();  //filter ingredients by label
  }

  Future<void> _findResults(String scannedIngredient) async{
    await FirebaseFirestore.instance.collection("ingredients")
        .where("lowercaseName", isEqualTo: scannedIngredient).get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        //Add name as key and fields as value
         results[element.data()['name']] = [element.data()['description'],
          element.data()['color'], element.data()['label']];
         return;
        });
      }).catchError((error){
        print("Fail to load all ingredients");
        print(error);
      });
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

  //checks if results is empty, sends filtered data to search page and resets counters
  void searchResultsPage(double textScale){
    if(results.isEmpty){
      showDialog(
          context: context,
          builder: (context){
            filteringResults = false; //reset click states to avoid bugs if user backs out of popup
            onClickResults = false;
            return  AlertDialog(
              buttonPadding: EdgeInsets.all(0.8),
              backgroundColor: widget.isDarkModeEnabled ?Colors.blueGrey[900]: Colors.white,
              title: AutoSizeText(
                  "Alert",
                  maxLines: 1,
                  presetFontSizes: [18, 15, 14],
                  minFontSize: 12,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    AutoSizeText(
                        "No ingredients found. Please try again and make sure to focus "
                        "camera on the ingredient label.",
                        maxLines: 4,
                        presetFontSizes: [15, 14, 12],
                        minFontSize: 12,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed:  () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage(title: "Home Page", isDarkModeEnabled: widget.isDarkModeEnabled,)),
                    ),
                    child: AutoSizeText(
                        "OK",
                        maxLines: 1,
                        presetFontSizes: [15, 14, 12],
                        minFontSize: 12,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
                    )
                )
              ],
            );
          }
      );
    }
    //if results are not empty, than go to search_results page
    setState((){
        if(results.isNotEmpty)
          Navigator.push( //change from one screen to another
            context,
            MaterialPageRoute(builder: (context) => MySearchResultsPage(title: 'Results',
                foundIngred: results, numOfgreenIngred: numOfGreenIngred,
                numOfredIngred: numOfRedIngred, numOfyellowIngred: numOfYellowIngred,
                scannedImage: Image.file(File(imageFile!.path)), imageUrl: pugImageUrl,
                isDarkModeEnabled: widget.isDarkModeEnabled, grade: grade, gradeColor: gradeColor,
                pieChartData: pieChartData,
            ))).then((value) => reset());
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
        primary:Color(0xFF7E57C2),
      ),

      scaffoldBackgroundColor: Colors.grey[50],
      primaryColor: Colors.white,
      brightness: Brightness.light,
      dividerColor: Colors.white54,

    //     List<Color> lightGradient = [Color(0xFF9C27B0), Color(0xFF673AB7)];
    // List<Color> darkGradient = [Color(0xFF253341), Color(0xFF212121)];
    );
  }
 ThemeData darkTheme(){
    return ThemeData(
      appBarTheme: AppBarTheme(color: const Color(0xFF253341),),
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
      this.widget.isDarkModeEnabled = isDarkModeEnabled;
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
      if(results.values.elementAt(i).elementAt(1) == "neutral"){ //if name.color == neutral
        overallRating += point; //full point
      }
      if(results.values.elementAt(i).elementAt(1) == "yellow"){
        overallRating += (point/2); //half point
        //check once if yellow in first 5 ingredients subtract bonus point once
        //make sure there is more than 5 ingredients to add bonus points
        if(i < 5 && checkFirstFiveYellow == false && results.keys.length > 5){
          bonus -= 3.0; //bonus point is -3
          checkFirstFiveYellow = true;
        }
      }
      if(results.values.elementAt(i).elementAt(1) == "red"){
        overallRating += 0.0; //no point
        //check once if red in first 5 ingredients subtract bonus point once
        //make sure there is more than 5 ingredients to add bonus points
        if(i < 5 && checkFirstFiveRed == false && results.keys.length > 5){
          bonus -= 5.0; //bonus point is -5
          checkFirstFiveRed = true;
        }
      }
      if(results.values.elementAt(i).elementAt(1) == "green"){ //if name.color == green
        overallRating += point; //full point
        //check once if all green in first 5 ingredients then add bonus point once
        if(i == 4 && checkFirstFiveGreen == false && checkFirstFiveYellow != true
            && checkFirstFiveRed != true){
          bonus += 5.0; //bonus point is +5
          checkFirstFiveGreen = true;
        }
      }
    }
    overallRating += bonus; //add bonus points to overall rating
    print("Overall Rating");
    print(overallRating);
    print("Bonus Points");
    print(bonus);

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

  //filters ingredients by label for pie chart data
  void setPieChartData(){
    double numOfMeat = 0;
    double numOfFishShellfish = 0;
    double numOfGrain = 0;
    double numOfVegetable = 0;
    double numOfFruitsBeansSeeds = 0;
    double numOfHerbs = 0;
    double numOfSupplements = 0;
    double numOfAdditives = 0;
    double numOfOther = 0;

    for(var i = 0; i < results.keys.length; i++){
      if(results.values.elementAt(i).elementAt(2) == "Meats"){
        numOfMeat+= 1;
        pieChartData["Meats"] = numOfMeat;
      }
      else if (results.values.elementAt(i).elementAt(2) == "Fish & Shellfish"){
        numOfFishShellfish+= 1;
        pieChartData["Fish & Shellfish"] = numOfFishShellfish;
      }
      else if(results.values.elementAt(i).elementAt(2) == "Grains"){
        numOfGrain+= 1;
        pieChartData["Grains"] = numOfGrain;
      }
      else if(results.values.elementAt(i).elementAt(2) == "Vegetables"){
        numOfVegetable+= 1;
        pieChartData["Vegetables"] = numOfVegetable;
      }
      else if(results.values.elementAt(i).elementAt(2) == "Fruits, Beans & Seeds"){
        numOfFruitsBeansSeeds += 1;
        pieChartData["Fruits, Beans & Seeds"] = numOfFruitsBeansSeeds;
      }
      else if(results.values.elementAt(i).elementAt(2) == "Herbs"){
        numOfHerbs+= 1;
        pieChartData["Herbs"] = numOfHerbs;
      }
      else if(results.values.elementAt(i).elementAt(2) == "Supplements"){
        numOfSupplements+= 1;
        pieChartData["Supplements"] = numOfSupplements;
      }
      else if(results.values.elementAt(i).elementAt(2) == "Additives"){
        numOfAdditives+= 1;
        pieChartData["Additives"] = numOfAdditives;
      }
      else{
        numOfOther+= 1;
        pieChartData["Other"] = numOfOther;
      }
    }
    //if there is a label that hasn't been found, than store default data to zero
    if(numOfMeat == 0){
      pieChartData["Meats"] = 0;
    }
    if (numOfFishShellfish == 0){
      pieChartData["Fish & Shellfish"] = 0;
    }
    if(numOfGrain == 0){
      pieChartData["Grains"] = 0;
    }
    if(numOfVegetable == 0){
      pieChartData["Vegetables"] = 0;
    }
    if(numOfFruitsBeansSeeds== 0){
      pieChartData["Fruits, Beans & Seeds"] = 0;
    }
    if(numOfHerbs == 0){
      pieChartData["Herbs"] = 0;
    }
    if(numOfSupplements == 0){
      pieChartData["Supplements"] = 0;
    }
    if(numOfAdditives == 0){
      pieChartData["Additives"] = 0;
    }
    if(numOfOther == 0){
      pieChartData["Other"] = 0;
    }
    print("Pie chart data");
    print(pieChartData);
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
