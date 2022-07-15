import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:pie_chart/pie_chart.dart';

class MySearchResultsPage extends StatefulWidget {
  const MySearchResultsPage({Key? key, required this.title, required this.foundIngred,
  required this.numOfgreenIngred, required this.numOfredIngred, required this.numOfyellowIngred,
  required this.scannedImage, required this.imageUrl, required this.isDarkModeEnabled,
  required this.grade, required this.gradeColor, required this.pieChartData})
      : super(key: key);//constructor
  final String title; //attribute
  final int numOfgreenIngred;
  final int numOfredIngred;
  final int  numOfyellowIngred;
  final Image scannedImage;
  final bool isDarkModeEnabled;
  final Map<String, List<String>> foundIngred;
  final Map<String, double> grade;
  final Map<String, double> pieChartData;
  final imageUrl;
  final Color gradeColor;

  @override
  State<MySearchResultsPage> createState() => _MySearchResultsState();
}

class _MySearchResultsState extends State<MySearchResultsPage> {
  Map<String, List<String>> results = {};
  List<String> keys = [];
  bool _isVisible = false;
  bool _isVisible2 = false;
  bool pressed1 = true;
  bool pressed2 = true;
  Text rating = Text("");
  Map<String,Color> btnColor = {};
  var myGroup1 = AutoSizeGroup(); //synchronize font sizes
  var myGroup2 = AutoSizeGroup();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState(){
    super.initState();
    setAttributes(); //Access widget attributes
    setButtonColor(); //dynamically set background color
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: widget.isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      home:  Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              splashRadius: 0.5,
              padding: EdgeInsets.only(left: 10),
              alignment: Alignment.centerLeft,
                onPressed: () => mainPage(),
                icon: Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 27,
                ),
            ),
          ],
          title: AutoSizeText(
              "Results",
              textAlign: TextAlign.left,
              maxLines: 1,
              minFontSize: 12,
              presetFontSizes: [20, 18, 14],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20)
          ),

        ),
        body:
            GlowingOverscrollIndicator(
              axisDirection: AxisDirection.down,
              color:  Colors.deepPurple,
              child: Scrollbar(
                controller: _scrollController,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.all(5),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Expanded(
                                    //     flex: 1,
                                    //     child: Container(
                                    //       alignment: Alignment.topLeft,
                                    //       height: MediaQuery.of(context).size.height,
                                    //       constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.3),
                                    //       child: widget.scannedImage,
                                    //     )
                                    // ),

                                    //display pug image along with overall rating
                                    if(widget.imageUrl != null)
                                      Expanded(
                                          flex: 1,
                                          child: Container(
                                              //padding: EdgeInsets.all(1),
                                              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4, maxWidth: MediaQuery.of(context).size.width),
                                              alignment: Alignment.center,
                                              child:
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width /2,
                                                        height: MediaQuery.of(context).size.height,
                                                        child:  Image.network(
                                                          widget.imageUrl,
                                                        ),
                                                      ),

                                                      Column(
                                                        mainAxisSize: MainAxisSize.max,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            mainAxisSize: MainAxisSize.max,
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets.only(top:1, bottom: 5, left: 2),
                                                                child: AutoSizeText(
                                                                    "Overall Rating",
                                                                    maxLines: 1,
                                                                    minFontSize: 12,
                                                                    presetFontSizes: [15, 14, 12],
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900],)
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 30,
                                                                  width: 25,
                                                                  child:  IconButton(
                                                                    alignment: Alignment.center,
                                                                    splashRadius: 7,
                                                                    splashColor: Colors.blueAccent,
                                                                    hoverColor: Colors.blueAccent,
                                                                    iconSize: 15,
                                                                    padding: EdgeInsets.all(1),
                                                                    icon: Icon(Icons.info_rounded),
                                                                    color: Colors.blue[400],
                                                                    onPressed: (){
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (context){
                                                                          return Dialog(
                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                              elevation: 16,
                                                                              child: Container(
                                                                                height: 500,
                                                                                decoration: BoxDecoration(  //decorate popup
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
                                                                                //display pop-up description to overall rating
                                                                                child: GlowingOverscrollIndicator(
                                                                                    axisDirection: AxisDirection.down,
                                                                                    color:  Colors.deepPurple,
                                                                                    child:  ListView(
                                                                                      padding: EdgeInsets.all(10),
                                                                                      shrinkWrap: true,
                                                                                      children: [
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                                                          child: Text("How is the Overall Rating calculated?",
                                                                                              style: TextStyle(fontSize: 18, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                              textAlign: TextAlign.left
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                                                          child:  Text("The 'Overall Rating' is calculated out of one hundred. "
                                                                                              "When the ingredient list is filtered through the algorithm, "
                                                                                              "it reads the rating of each ingredient and either adds or "
                                                                                              "subtracts point. If a ingredient is green or blue then the "
                                                                                              "algorithm adds points, if a ingredient is yellow "
                                                                                              "then the algorithm adds half-points and if the ingredient "
                                                                                              "is red then no points are added. Additional points are either "
                                                                                              "added or subtracted depending on the first 5 ingredients. If the "
                                                                                              "first five ingredients are all green/blue than a +5 bonus point is added "
                                                                                              "added, if there contains a yellow then -3 bonus point is subtracted, "
                                                                                              "and if there contains a red a -5 bonus point is subtracted. Finally, "
                                                                                              "the overall ingredient rating is compared to a grading scale.",
                                                                                              style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                              textAlign: TextAlign.left
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                            padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0, top: 10.0),
                                                                                            child:
                                                                                            Container(
                                                                                              child: Text("Each individual ingredient rating is calculated with consideration to AAFCO and "
                                                                                                  "AllAboutDogFood.co.uk",
                                                                                                  style: TextStyle(fontSize: 15,color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                                  textAlign: TextAlign.left
                                                                                              ),
                                                                                              color: widget.isDarkModeEnabled ?Colors.grey[600]: Colors.grey[100],
                                                                                              padding: EdgeInsets.all(8),
                                                                                            )
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0, top:10.0),
                                                                                          child: Text("Grading Scale",
                                                                                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                              textAlign: TextAlign.left),

                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                                                          child:  Text("A+: Above 97%",
                                                                                              style: TextStyle(
                                                                                                  fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                              textAlign: TextAlign.left),

                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                                                          child:
                                                                                          Text("A: 93-96%",
                                                                                              style: TextStyle(
                                                                                                  fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                              textAlign: TextAlign.left),


                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                                                          child: Text("A-: 90-92%",
                                                                                              style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                              textAlign: TextAlign.left),

                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                                                          child: Text("B+: 87-89%",
                                                                                              style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                              textAlign: TextAlign.left),

                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                                                          child:  Text("B: 83-86%",
                                                                                              style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                              textAlign: TextAlign.left),

                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                                                          child:Text("B-: 80-82%",
                                                                                              style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                              textAlign: TextAlign.left),

                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                                                          child:Text("C+: 77-79%",
                                                                                              style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                              textAlign: TextAlign.left),

                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                                                          child:
                                                                                          Text("C: 73-76%",
                                                                                              style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                              textAlign: TextAlign.left),

                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                                                          child:Text("C-: 70-72%",
                                                                                              style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                              textAlign: TextAlign.left),

                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                                                          child:Text("D+: 67-69%",
                                                                                              style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                              textAlign: TextAlign.left),

                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                                                          child:Text("D: 63-66%",
                                                                                              style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                              textAlign: TextAlign.left),

                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                                                          child:  Text("D-: 60-62%",
                                                                                              style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                              textAlign: TextAlign.left),

                                                                                        ),
                                                                                        Padding(
                                                                                          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                                                          child:    Text("F: Below 60%",
                                                                                              style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                              textAlign: TextAlign.left),
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                ),
                                                                              )
                                                                          );
                                                                        },
                                                                      );
                                                                      setState((){});
                                                                    },
                                                                  )
                                                              ),
                                                            ],
                                                          ),
                                                          Expanded(
                                                            // flex: 0,
                                                            child: Container(
                                                              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.1),
                                                              alignment: Alignment.center,
                                                              padding: EdgeInsets.all(5),
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Center(
                                                                    child: AutoSizeText(
                                                                      "${widget.grade.keys.elementAt(0)}",
                                                                      maxLines: 1,
                                                                      minFontSize: 12,
                                                                      presetFontSizes: [15, 14, 12],
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold,),
                                                                      textAlign: TextAlign.center,
                                                                    ),
                                                                  ),
                                                                  Center(
                                                                    child: AutoSizeText(
                                                                      "${widget.grade.values.elementAt(0).toStringAsFixed(1)}%",
                                                                      maxLines: 1,
                                                                      minFontSize: 12,
                                                                      presetFontSizes: [15, 14, 12],
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                                                                      textAlign: TextAlign.center,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  color: widget.gradeColor,
                                                                  shape: BoxShape.circle,
                                                                  boxShadow:[
                                                                    BoxShadow(
                                                                      color: widget.isDarkModeEnabled ?Color(0xFF253341).withOpacity(0.5):Color(0xFFBDBDBD).withOpacity(0.5),
                                                                      spreadRadius: 3,
                                                                      blurRadius: 7,
                                                                      offset: Offset(0, 3), // changes position of shadow
                                                                    ),
                                                                  ]
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  )

                                          )
                                      )
                                  ],
                                )
                            )

                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(padding: EdgeInsets.only(left: 10),
                              child: Icon(
                                Icons.check_rounded,
                                color: Colors.lightGreen,
                              ),
                            ),
                            Expanded(
                              child: AutoSizeText(
                                "${widget.numOfgreenIngred} Healthy",
                                maxLines: 1,
                                minFontSize: 12,
                                presetFontSizes: [15, 14, 12],
                                overflow: TextOverflow.ellipsis,
                                group: myGroup1,
                                style: TextStyle(color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900], fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                              flex: 0,
                            ),
                            Icon(
                              Icons.report_problem_rounded,
                              color: Colors.amber,
                            ),
                            Expanded(
                              child: AutoSizeText(
                                "${widget.numOfyellowIngred} Caution",
                                maxLines: 1,
                                minFontSize: 12,
                                presetFontSizes: [15, 14, 12],
                                overflow: TextOverflow.ellipsis,
                                group: myGroup1,
                                style: TextStyle(color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900], fontSize: 15,fontWeight: FontWeight.w500),
                              ),
                              flex: 0,

                            ),
                            Icon(
                              Icons.close_rounded,
                              color: Colors.red,
                            ),
                            Expanded(
                              child: AutoSizeText(
                                "${widget.numOfredIngred} Unhealthy",
                                maxLines: 1,
                                minFontSize: 12,
                                presetFontSizes: [15, 14, 12],
                                overflow: TextOverflow.ellipsis,
                                group: myGroup1,
                                style: TextStyle(color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900], fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                              //flex: 0,
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Padding(
                              padding:  EdgeInsets.only(left: 10, top: 10),
                              child: ButtonTheme(
                                child: TextButton.icon(
                                  label: AutoSizeText(
                                      "Analysis",
                                      maxLines: 1,
                                      minFontSize: 12,
                                      presetFontSizes: [15, 14, 12],
                                      overflow: TextOverflow.ellipsis,
                                      group: myGroup2,
                                      style: TextStyle(color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900], fontSize: 15, fontWeight: FontWeight.bold)),
                                  onPressed: (){
                                    setState((){
                                      pressed1 = !pressed1;
                                      _isVisible = false;
                                    });
                                    pressed2 = true;
                                    showPieChart();
                                  },
                                  style: pressed1 //Analysis btn decoration on press
                                      ?TextButton.styleFrom(
                                    shape: BeveledRectangleBorder(),

                                  ): TextButton.styleFrom(
                                    shape: BeveledRectangleBorder(),
                                    backgroundColor: widget.isDarkModeEnabled ?Colors.grey[800]: Colors.deepPurple[100],
                                  ),

                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: pressed1 ?Colors.grey: Color(0xFF212121),
                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child:  ButtonTheme(
                                child: TextButton.icon(
                                  label: AutoSizeText(
                                      "Ingredient List",
                                      maxLines: 1,
                                      minFontSize: 12,
                                      presetFontSizes: [15, 14, 12],
                                      overflow: TextOverflow.ellipsis,
                                      group: myGroup2,
                                      style:
                                      TextStyle(color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900], fontSize: 15, fontWeight: FontWeight.bold)),
                                  onPressed: (){
                                    setState((){
                                      pressed2 = !pressed2;
                                      _isVisible2 = false;
                                    });
                                    //Ingredient btn is pressed so un-press Analysis btn
                                    pressed1 = true;
                                    showIngredients(); //Controls visibility
                                  },
                                  style: pressed2 //Ingredients btn decoration on press
                                      ?TextButton.styleFrom(
                                    shape: BeveledRectangleBorder(),

                                  ): TextButton.styleFrom(
                                    shape: BeveledRectangleBorder(),
                                    primary: Colors.blueGrey[900],
                                    backgroundColor: widget.isDarkModeEnabled ?Colors.grey[800]: Colors.deepPurple[100],
                                  ),

                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: pressed2 ?Colors.grey: Color(0xFF212121),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Stack(  //shows analysis btn info or ingredients btn info
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child:
                              Visibility(
                                visible: _isVisible2,
                                child: SingleChildScrollView(
                                    padding: EdgeInsets.all(8.0),
                                    scrollDirection: Axis.vertical,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(top: 5, bottom: 10),
                                              child: AutoSizeText(
                                                  "Ingredient List Categories",
                                                  maxLines: 1,
                                                  minFontSize: 12,
                                                  presetFontSizes: [18, 15, 14],
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900], fontSize: 18)
                                              ),
                                            ),
                                            SizedBox(
                                              height: 30,
                                              width: 25,
                                              child: IconButton(
                                                splashRadius: 10,
                                                splashColor: Colors.blueAccent,
                                                hoverColor: Colors.blueAccent,
                                                iconSize: 15,
                                                padding: EdgeInsets.all(1),
                                                icon: Icon(Icons.info_rounded),
                                                color: Colors.blue[400],
                                                onPressed: (){
                                                  showDialog(
                                                    context: context,
                                                    builder: (context){
                                                      return Dialog(
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                          elevation: 16,
                                                          child: Container(
                                                            height: 500,
                                                            decoration: BoxDecoration(  //decorate popup
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
                                                            child: GlowingOverscrollIndicator(
                                                              axisDirection: AxisDirection.down,
                                                              color:  Colors.deepPurple,
                                                              child: ListView(
                                                                padding: EdgeInsets.all(10),
                                                                shrinkWrap: true,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                                    child: AutoSizeText(
                                                                        "What is the Ingredient List Categories?",
                                                                        style: TextStyle(fontSize: 18, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                        textAlign: TextAlign.left
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                                    child: AutoSizeText("The 'Ingredient List Categories' displays segments that each "
                                                                        "represents a percentage of ingredients found in a given category. Each "
                                                                        "segment represents a particular category, which is explained below.",
                                                                        style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                        textAlign: TextAlign.left
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0, top: 10.0),
                                                                      child:
                                                                      Container(
                                                                        child:  RichText(
                                                                            text: TextSpan(
                                                                              children:[
                                                                                WidgetSpan(
                                                                                    child: Padding(
                                                                                        padding: EdgeInsets.only(right: 3),
                                                                                        child: Icon(
                                                                                          Icons.circle_rounded,
                                                                                          color: Color(0xFFFF5252),
                                                                                          size: 15,
                                                                                        )
                                                                                    )
                                                                                ),
                                                                                TextSpan(
                                                                                  text: "Meats - includes all meat ingredients and animal by-products except fish ingredients",
                                                                                  style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                )
                                                                              ],
                                                                            )
                                                                        ),
                                                                        color: widget.isDarkModeEnabled ?Colors.grey[600]: Colors.grey[100],
                                                                        padding: EdgeInsets.all(8),
                                                                      )
                                                                  ),
                                                                  Padding(
                                                                      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0, top: 10.0),
                                                                      child: Container(
                                                                        child: RichText(
                                                                            text: TextSpan(
                                                                              children:[
                                                                                WidgetSpan(
                                                                                    child: Padding(
                                                                                        padding: EdgeInsets.only(right: 3),
                                                                                        child: Icon(
                                                                                          Icons.circle_rounded,
                                                                                          color: Color(0xFF80D8FF),
                                                                                          size: 15,
                                                                                        )
                                                                                    )
                                                                                ),
                                                                                TextSpan(
                                                                                  text: "Supplements - includes vitamins, minerals, and probiotics",
                                                                                  style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                )
                                                                              ],
                                                                            )
                                                                        ),
                                                                        color: widget.isDarkModeEnabled ?Colors.grey[600]: Colors.grey[100],
                                                                        padding: EdgeInsets.all(8),
                                                                      )
                                                                  ),
                                                                  Padding(
                                                                      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0, top: 10.0),
                                                                      child: Container(
                                                                        child:  RichText(
                                                                            text: TextSpan(
                                                                              children:[
                                                                                WidgetSpan(
                                                                                    child: Padding(
                                                                                        padding: EdgeInsets.only(right: 3),
                                                                                        child: Icon(
                                                                                          Icons.circle_rounded,
                                                                                          color: Color(0xFF69F0AE),
                                                                                          size: 15,
                                                                                        )
                                                                                    )
                                                                                ),
                                                                                TextSpan(
                                                                                  text: "Other - all other ingredients that do not fall under any ingredient category. "
                                                                                      "Mostly includes compounds of an ingredient or chemical forms",
                                                                                  style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                )
                                                                              ],
                                                                            )
                                                                        ),
                                                                        color: widget.isDarkModeEnabled ?Colors.grey[600]: Colors.grey[100],
                                                                        padding: EdgeInsets.all(8),
                                                                      )
                                                                  ),
                                                                  Padding(
                                                                      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0, top: 10.0),
                                                                      child:  Container(
                                                                        child:  RichText(
                                                                            text: TextSpan(
                                                                              children:[
                                                                                WidgetSpan(
                                                                                    child: Padding(
                                                                                        padding: EdgeInsets.only(right: 3),
                                                                                        child: Icon(
                                                                                          Icons.circle_rounded,
                                                                                          color: Color(0xFFFFFF00),
                                                                                          size: 15,
                                                                                        )
                                                                                    )
                                                                                ),
                                                                                TextSpan(
                                                                                  text: "Fish & Shellfish - includes all fish ingredients and fish by-products",
                                                                                  style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                )
                                                                              ],
                                                                            )
                                                                        ),
                                                                        color: widget.isDarkModeEnabled ?Colors.grey[600]: Colors.grey[100],
                                                                        padding: EdgeInsets.all(8),
                                                                      )
                                                                  ),
                                                                  Padding(
                                                                      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0, top: 10.0),
                                                                      child: Container(
                                                                        child:  RichText(
                                                                            text: TextSpan(
                                                                              children:[
                                                                                WidgetSpan(
                                                                                    child: Padding(
                                                                                        padding: EdgeInsets.only(right: 3),
                                                                                        child: Icon(
                                                                                          Icons.circle_rounded,
                                                                                          color: Color(0xFFB388FF),
                                                                                          size: 15,
                                                                                        )
                                                                                    )
                                                                                ),
                                                                                TextSpan(
                                                                                  text: "Grains - includes wheat, corn, rice, barely or any other cereal grain",
                                                                                  style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                )
                                                                              ],
                                                                            )
                                                                        ),
                                                                        color: widget.isDarkModeEnabled ?Colors.grey[600]: Colors.grey[100],
                                                                        padding: EdgeInsets.all(8),
                                                                      )
                                                                  ),
                                                                  Padding(
                                                                      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0, top: 10.0),
                                                                      child: Container(
                                                                        child: RichText(
                                                                            text: TextSpan(
                                                                              children:[
                                                                                WidgetSpan(
                                                                                    child: Padding(
                                                                                        padding: EdgeInsets.only(right: 3),
                                                                                        child: Icon(
                                                                                          Icons.circle_rounded,
                                                                                          color: Color(0xFFFF80AB),
                                                                                          size: 15,
                                                                                        )
                                                                                    )
                                                                                ),
                                                                                TextSpan(
                                                                                  text: "Vegetables - includes all whole vegetables and vegetable oils, "
                                                                                      " excluding seed oils",
                                                                                  style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                )
                                                                              ],
                                                                            )
                                                                        ),
                                                                        color: widget.isDarkModeEnabled ?Colors.grey[600]: Colors.grey[100],
                                                                        padding: EdgeInsets.all(8),
                                                                      )
                                                                  ),
                                                                  Padding(
                                                                      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0, top: 10.0),
                                                                      child: Container(
                                                                        child: RichText(
                                                                            text: TextSpan(
                                                                              children:[
                                                                                WidgetSpan(
                                                                                    child: Padding(
                                                                                        padding: EdgeInsets.only(right: 3),
                                                                                        child: Icon(
                                                                                          Icons.circle_rounded,
                                                                                          color: Color(0xFFFFAB40),
                                                                                          size: 15,
                                                                                        )
                                                                                    )
                                                                                ),
                                                                                TextSpan(
                                                                                  text: "Fruits, Beans, & Seeds - includes all whole fruits, legumes, and oil seeds",
                                                                                  style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                )
                                                                              ],
                                                                            )
                                                                        ),
                                                                        color: widget.isDarkModeEnabled ?Colors.grey[600]: Colors.grey[100],
                                                                        padding: EdgeInsets.all(8),
                                                                      )
                                                                  ),
                                                                  Padding(
                                                                      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0, top: 10.0),
                                                                      child: Container(
                                                                        child: RichText(
                                                                            text: TextSpan(
                                                                              children:[
                                                                                WidgetSpan(
                                                                                    child: Padding(
                                                                                        padding: EdgeInsets.only(right: 3),
                                                                                        child: Icon(
                                                                                          Icons.circle_rounded,
                                                                                          color: Color(0xFFB2FF59),
                                                                                          size: 15,
                                                                                        )
                                                                                    )
                                                                                ),
                                                                                TextSpan(
                                                                                  text: "Herbs - includes any plants with leaves, seeds, or flowers used for "
                                                                                      "their flavour, aroma, nutritional constituents or medicinal properties ",
                                                                                  style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                )
                                                                              ],
                                                                            )
                                                                        ),
                                                                        color: widget.isDarkModeEnabled ?Colors.grey[600]: Colors.grey[100],
                                                                        padding: EdgeInsets.all(8),
                                                                      )
                                                                  ),
                                                                  Padding(
                                                                      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0, top: 10.0),
                                                                      child: Container(
                                                                        child: RichText(
                                                                            text: TextSpan(
                                                                              children:[
                                                                                WidgetSpan(
                                                                                    child: Padding(
                                                                                        padding: EdgeInsets.only(right: 3),
                                                                                        child: Icon(
                                                                                          Icons.circle_rounded,
                                                                                          color: Color(0xFF536DFE),
                                                                                          size: 15,
                                                                                        )
                                                                                    )
                                                                                ),
                                                                                TextSpan(
                                                                                  text: "Additives - includes preservatives, added colouring, and added flavours",
                                                                                  style: TextStyle(fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                                )
                                                                              ],
                                                                            )
                                                                        ),
                                                                        color: widget.isDarkModeEnabled ?Colors.grey[600]: Colors.grey[100],
                                                                        padding: EdgeInsets.all(8),
                                                                      )
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                          )
                                                      );
                                                    },
                                                  );
                                                  setState((){});
                                                },
                                              ),
                                            )
                                          ],
                                        ),

                                        PieChart(
                                          chartType: ChartType.ring,
                                          chartLegendSpacing: 32,
                                          colorList: [
                                            Color(0xFFFF5252),
                                            Color(0xFF80D8FF),
                                            Color(0xFF69F0AE),
                                            Color(0xFFFFFF00),
                                            Color(0xFFB388FF),
                                            Color(0xFFFF80AB),
                                            Color(0xFFFFAB40),
                                            Color(0xFFB2FF59),
                                            Color(0xFF536DFE),
                                          ],
                                          ringStrokeWidth: 20,
                                          chartRadius:  MediaQuery.of(context).size.width * 0.7,  //determines the size of the chart
                                          legendOptions: LegendOptions(
                                            showLegendsInRow: false,
                                            legendPosition: LegendPosition.bottom,
                                            showLegends: true,
                                            legendTextStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                overflow: TextOverflow.ellipsis,
                                                color:  widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]
                                            ),
                                          ),
                                          chartValuesOptions: ChartValuesOptions(
                                            showChartValueBackground: true,
                                            showChartValues: true,
                                            showChartValuesInPercentage: true,
                                            showChartValuesOutside: false,
                                            decimalPlaces: 1,
                                          ),
                                          dataMap: widget.pieChartData,
                                        )
                                      ],
                                    )
                                ),
                              ),
                            ),

                            Align(
                              alignment: Alignment.topCenter,
                              child: Visibility( //show and hide ingredients
                                  visible: _isVisible,
                                  child: SingleChildScrollView(
                                    padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 3, bottom: 3),
                                    scrollDirection: Axis.vertical,
                                    child: Column(  //dynamically display ingredients
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
                                                          color: widget.isDarkModeEnabled ?Colors.grey[800]: Colors.white,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey.withOpacity(0.5),
                                                              spreadRadius: 2,
                                                              blurRadius: 7,
                                                              offset: Offset(2,3),
                                                            ),
                                                          ]
                                                      ),
                                                      child: GlowingOverscrollIndicator(
                                                        axisDirection: AxisDirection.down,
                                                        color:  Colors.deepPurple,
                                                        child: ListView(
                                                          padding: EdgeInsets.all(10),
                                                          shrinkWrap: true,
                                                          children: [
                                                            SizedBox(height: 20),
                                                            Center( //display ingredient name
                                                                child: AutoSizeText(
                                                                    ingredient,
                                                                    maxLines: 1,
                                                                    minFontSize: 12,
                                                                    presetFontSizes: [18, 15, 14],
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]))
                                                            ),
                                                            Column( //display ingredient description
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                SizedBox(height: 12),
                                                                Container(height: 2),
                                                                Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsets.only(left: 4.0),
                                                                      child:  Icon(
                                                                        Icons.lightbulb,
                                                                        color: Colors.amber,
                                                                      ),
                                                                    ),
                                                                    AutoSizeText(
                                                                        "Description",
                                                                        maxLines: 1,
                                                                        minFontSize: 12,
                                                                        presetFontSizes: [15, 14, 12],
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                        textAlign: TextAlign.left
                                                                    ),
                                                                  ],
                                                                ),
                                                                Padding(
                                                                    padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 4.0),
                                                                    child: AutoSizeText(
                                                                      "${results[ingredient]?.elementAt(0)}",
                                                                      style: TextStyle(height: 1.5, fontSize: 15, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),

                                                                    )
                                                                ),
                                                                Row(  //display ingredient rating
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsets.only(left: 4.0),
                                                                      child: Icon(
                                                                        Icons.health_and_safety_rounded,
                                                                        color: btnColor[ingredient],
                                                                      ),
                                                                    ),
                                                                    if(btnColor[ingredient].toString() == "MaterialColor(primary value: Color(0xff4caf50))")
                                                                      AutoSizeText(
                                                                          "Recommended",
                                                                          maxLines: 1,
                                                                          minFontSize: 12,
                                                                          presetFontSizes: [15, 14, 12],
                                                                          overflow: TextOverflow.ellipsis,
                                                                          style: TextStyle(fontSize: 15 , fontWeight: FontWeight.bold, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
                                                                      ),

                                                                    if (btnColor[ingredient].toString() == "MaterialColor(primary value: Color(0xffffc107))")
                                                                      AutoSizeText(
                                                                          "Not Recommended",
                                                                          maxLines: 1,
                                                                          minFontSize: 12,
                                                                          presetFontSizes: [15, 14, 12],
                                                                          overflow: TextOverflow.ellipsis,
                                                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
                                                                      ),

                                                                    if (btnColor[ingredient].toString() == "MaterialColor(primary value: Color(0xfff44336))")
                                                                      AutoSizeText(
                                                                          "Avoid",
                                                                          maxLines: 1,
                                                                          minFontSize: 12,
                                                                          presetFontSizes: [15, 14, 12],
                                                                          overflow: TextOverflow.ellipsis,
                                                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
                                                                      ),

                                                                    if(btnColor[ingredient].toString() == "MaterialAccentColor(primary value: Color(0xff40c4ff))")
                                                                      AutoSizeText(
                                                                          "General ingredient definition",
                                                                          maxLines: 1,
                                                                          minFontSize: 12,
                                                                          presetFontSizes: [15, 14, 12],
                                                                          overflow: TextOverflow.ellipsis,
                                                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900])
                                                                      ),
                                                                    //displayRating(btnColor[ingredient].toString())
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(right: 10.0, bottom: 4.0),
                                                              child: Row( //display ingredient label
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(left: 4.0),
                                                                    child:  Icon(
                                                                      Icons.label,
                                                                      color: Colors.purple[400],
                                                                    ),
                                                                  ),
                                                                  AutoSizeText(
                                                                    "${results[ingredient]?.elementAt(2)}",
                                                                    maxLines: 1,
                                                                    minFontSize: 12,
                                                                    presetFontSizes: [15, 14, 12],
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: TextStyle(height: 1.5, fontSize: 15, fontWeight: FontWeight.bold, color: widget.isDarkModeEnabled ?Colors.white: Colors.blueGrey[900]),
                                                                  )
                                                                ],
                                                              ),
                                                            )

                                                          ],
                                                        ),

                                                      ),
                                                    ),
                                                  );
                                                }
                                            );
                                          },
                                          style: ButtonStyle( //display ingredient btn color
                                            backgroundColor: MaterialStateProperty.all(btnColor[ingredient]),
                                            alignment: Alignment.center,
                                            elevation: MaterialStateProperty.all(3),
                                            shadowColor:MaterialStateProperty.all(Colors.grey), //Defines shadowColor
                                          ),
                                          label: Align( //display ingredient name button
                                              alignment: Alignment.topLeft,
                                              child: AutoSizeText(
                                                  ingredient,
                                                  maxLines: 1,
                                                  minFontSize: 12,
                                                  presetFontSizes: [15, 14, 12],
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)
                                              )
                                          ),
                                          icon: Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.black54
                                          ),
                                        )).toList()
                                    ),

                                  )
                              ),
                            ),
                          ],
                        ),

                        //FOR FUTURE USE
                        // ElevatedButton(
                        //     onPressed: (){  //load data from fire store database
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
              ),
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

  void showIngredients(){
    setState((){
      _isVisible = !_isVisible;
    });
  }
  void showPieChart(){
    setState((){
      _isVisible2 = !_isVisible2;
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

  void mainPage(){
    setState((){
      Navigator.pushAndRemoveUntil( //on back reset screen //use .pop to keep content
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home', isDarkModeEnabled: widget.isDarkModeEnabled,)),
            (Route<dynamic> route) => false,
      );
      print("Now on Main Page");//debug
    });
  }
}

