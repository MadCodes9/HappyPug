import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MySearchResultsPage extends StatefulWidget {
  const MySearchResultsPage({Key? key, required this.title, required this.text})
      : super(key: key);//constructor
  final String title; //attribute
  final Map<String, List<String>>  text;

  @override
  State<MySearchResultsPage> createState() => _MySearchResultsState();
}

class _MySearchResultsState extends State<MySearchResultsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            
               Expanded(
                 child: Text(
                   "Good",
                   style: TextStyle(fontSize: 20),
                 ),
                 flex: 5,

               ),
               Expanded(
                 child: Text(
                   "Bad",
                   style: TextStyle(fontSize: 20),
                 ),
                 flex: 20,
               ),
             ],
           ),

            Container(
              child: Text(
                "Ingredients Found: ${widget.text.keys}", //From home screen
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
    );
  }
}

