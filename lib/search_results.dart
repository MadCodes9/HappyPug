import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MySearchResultsPage extends StatefulWidget {
  const MySearchResultsPage({Key? key, required this.title, required this.foundIngred,
  required this.numOfgreenIngred, required this.numOfredIngred, required this.numOfyellowIngred})
      : super(key: key);//constructor
  final String title; //attribute
  final Map<String, List<String>> foundIngred;
  final int numOfgreenIngred;
  final int numOfredIngred;
  final int  numOfyellowIngred;

  @override
  State<MySearchResultsPage> createState() => _MySearchResultsState();
}

class _MySearchResultsState extends State<MySearchResultsPage> {
  String foundLength = "";
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async{
          Navigator.pop(context);
          return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(5),
                alignment: Alignment.centerLeft,
                child: Image(
                  height: 200,
                  width: 200,
                  image: NetworkImage('https://i.pinimg.com/originals/53/cb/23/53cb231f4c04ae30a04a6e292eb2a48c.jpg'),
                ),
              ),
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
                      style: TextStyle(fontSize: 15),
                    ),
                    flex: 0,

                  ),
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.yellow,
                  ),
                  Expanded(
                    child: Text(
                      "${widget.numOfyellowIngred} Caution",
                      style: TextStyle(fontSize: 15),
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
                      style: TextStyle(fontSize: 15),
                    ),
                    //flex: 0,
                  ),
                ],
              ),

              Row(
               // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ButtonTheme(
                    child: MaterialButton(
                      onPressed: (){

                      },
                      child: Text("Overall"),
                    ),
                  ),
                  ButtonTheme(
                    child: MaterialButton(
                      onPressed: (){

                      },
                      child: Text("Ingredients"),
                    ),
                  ),

                ],
              ),

              Container(
                child: Text(
                  "Ingredients Found: ${widget.foundIngred.keys}", //From home screen
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                  onPressed: (){  //load data from firestore database
                    FirebaseFirestore.instance.collection("ingredients").get()
                        .then((querySnapshot) {
                      print("Successfully load all ingredients");
                      //print querySnapshot
                      querySnapshot.docs.forEach((element) {
                        //print(element.data());
                        print(element.data()['name']);
                      });
                    }).catchError((error){
                      print("Fail to load all ingredients");
                      print(error);
                    });
                  },
                  child: Text("List all ingredients")
              )
            ]
        ),
      )
    );
  }
}
