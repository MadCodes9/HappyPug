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


//void main() => runApp(MyApp()); //lambda expression same as below format
void main() async {
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
  // ignore: avoid_print
  print(
    isConnected.toString(),
  );
  print(
    'Current status: ${await InternetConnectionChecker().connectionStatus}',
  );

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

class MyApp extends StatelessWidget { //global data, style of entire app
  MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Home')
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);//constructor
  String title; //attribute

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  bool textScanning = false;
  bool isDarkModeEnabled = false;
  bool filteringResults = false;
  bool onClickResults = false;
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
                    children:[
                      if(!textScanning && imageFile == null)
                        Column(
                          children: [
                            Text("Scan Ingredients", style: TextStyle(fontSize: 18 * textScale,
                            fontWeight: FontWeight.bold, color: isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5,right: 5,top: 6, bottom: 20),
                              child: Text("Focus camera on the ingredient list of your dog food product like below",
                                style: TextStyle(fontSize: 15 * textScale, color: Colors.blueGrey[600])),
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
                              Text("Captured Image", style: TextStyle(fontSize: 18 * textScale,
                                  fontWeight: FontWeight.bold, color: isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
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
                                if(textScanning)
                                  Column(
                                    children: [
                                      Text("Processing...", style: TextStyle(fontSize: 18 * textScale,
                                          fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ],
                                  ),
                                if(filteringResults == true)
                                  Column(
                                    children: [
                                      Text("Filtering Ingredients...", style: TextStyle(fontSize: 18 * textScale,
                                          fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ],
                                  ),
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

                      //once loading is done display buttons and results are not empty
                      if(textScanning == false && imageFile != null)
                        Column(
                            children:<Widget>[
                              Container(
                                child:
                                Padding(
                                    padding: EdgeInsets.all(10),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          //user can press btn only once
                                          if(onClickResults == false){
                                            filteringResults = true;
                                            //filter ingredients then calculate the ingredient rating
                                            // then load image from real time database and than go to result page
                                             _filterIngredients().then((value) => calculateOverallRating()).
                                            then((value) => loadPugImage()).then((value) => searchResultsPage());
                                          }
                                         onClickResults = true;
                                        },
                                        child: Text('View Results', style: TextStyle(fontSize: 14 * textScale))
                                    ),
                                ),
                              ),
                            ]
                        ),
                    ],
                  )
              ),
            )
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
    grade = {};
    setState((){});
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
    String trim_ingredients = scannedText.replaceAll(':', ','); //replace any semicolons with commas
    trim_ingredients = trim_ingredients.replaceAll('Ingredients', ','); //separate 'Ingredient
    trim_ingredients = trim_ingredients.replaceAll('(', ','); //separate '(' and ')' with commas to get actual ingredient name
    trim_ingredients = trim_ingredients.replaceAll(')', ',');
    List<String> scannedIngredients = trim_ingredients.split(","); //split ingredients after comma and store in list
    final len = scannedIngredients.length;

    //format scanned text,  first letter and second letter is capitalize capitalize the first letter
    // after space, delete all white space,
    for(var i = 0; i < len; i++){
      scannedIngredients[i] = scannedIngredients[i].titleCase;
      scannedIngredients[i] = scannedIngredients[i].split(" ").map((str) => str.capitalize).join(" ");
      scannedIngredients[i] = scannedIngredients[i].replaceAll(new RegExp(r"\s+"), "");
      print("Scanned Text");
      print(scannedIngredients[i]);
    }
        ReCase rc_name;
    await FirebaseFirestore.instance.collection("ingredients").get()
        .then((querySnapshot) {
      print("Successfully load all ingredients");
      querySnapshot.docs.forEach((element) {
        //format ingredients in database same above to compare
        rc_name = ReCase(element.data()['name']);
        String cc_name = rc_name.camelCase;
        String formatted_name = cc_name[0].toUpperCase() + cc_name.substring(1);//uppercase first character

        //find where ingredients in database == scanned ingredients and store in map
        for (var i = 0; i < len; i++) {
          if (scannedIngredients[i] == formatted_name) {
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
    setPieChartData();  //filter ingredients by label
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

  void noInternetPopup(){ //checks for Internet connection when app opens
    showDialog(
        context: context,
        builder: (context){
          filteringResults = false; //reset click states
          onClickResults = false;
          return AlertDialog(
            buttonPadding: EdgeInsets.all(0.8),
            backgroundColor: isDarkModeEnabled ?Colors.blueGrey[900]: Colors.white,
            title: Text("Check Your Internet Connection", style: TextStyle(fontSize: 18 , fontWeight: FontWeight.bold,
                color: isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Padding(
                    padding:EdgeInsets.only(bottom: 10),
                    child:  Icon(
                      Icons.signal_wifi_connected_no_internet_4_rounded,
                      color: Colors.blueAccent,
                      size: 40,
                    ),
                  ),
                  Text("It is taking a while to upload results.", style: TextStyle(fontSize: 15 ,
                      color: isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
                  ),
                  Text("Either check your connection or try again", style: TextStyle(fontSize: 15 ,
                      color: isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed:  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage(title: "Home Page")),
                  ),
                  child: Text("OK", style: TextStyle(fontSize: 15 ,
                      color: isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
                  )
              )
            ],
          );
        }
    );
    setState((){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(title: "Home Page")),
      ).then((value) => reset());
    });
  }

  //checks if results is empty, sends filtered data to search page and resets counters
  void searchResultsPage(){
    if(results.isEmpty){
      showDialog(
          context: context,
          builder: (context){
            filteringResults = false; //reset click states
            onClickResults = false;
            return  AlertDialog(
              buttonPadding: EdgeInsets.all(0.8),
              backgroundColor: isDarkModeEnabled ?Colors.blueGrey[900]: Colors.white,
              title: Text("Alert", style: TextStyle(fontSize: 18 , fontWeight: FontWeight.bold,
                  color: isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text("No ingredients found. Please try again and make sure to focus "
                        "camera on the ingredient label.", style: TextStyle(fontSize: 15 ,
                        color: isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed:  () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage(title: "Home Page")),
                    ),
                    child: Text("OK", style: TextStyle(fontSize: 15 ,
                        color: isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
                    )
                )
              ],
            );
          }
      );
    }
    setState((){
        if(results.isNotEmpty)
          Navigator.push( //change from one screen to another
            context,
            MaterialPageRoute(builder: (context) => MySearchResultsPage(title: 'Results',
                foundIngred: results, numOfgreenIngred: numOfGreenIngred,
                numOfredIngred: numOfRedIngred, numOfyellowIngred: numOfYellowIngred,
                scannedImage: Image.file(File(imageFile!.path)), imageUrl: pugImageUrl,
                isDarkModeEnabled: isDarkModeEnabled, grade: grade, gradeColor: gradeColor,
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
