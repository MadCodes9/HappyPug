import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class MySearchResultsPage extends StatefulWidget {
  const MySearchResultsPage({Key? key, required this.title}) : super(key: key);//constructor
  final String title; //attribute

  @override
  State<MySearchResultsPage> createState() => _MySearchResultsState();
}

class _MySearchResultsState extends State<MySearchResultsPage> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      //future:  ,
        builder: (context, snapshot){
          return   Scaffold(
              appBar: AppBar(
                title: Text(widget.title),
              ),
              body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,  //alignment
                    children: <Widget>[
                      ElevatedButton(
                          onPressed: (){
                            FirebaseFirestore.instance.collection("ingredients").get()
                                .then((querySnapshot) {
                              print("Successfully load all ingredients");
                              //print querySnapshot
                              querySnapshot.docs.forEach((element) {
                                print(element.data());
                                //print(element.data()['name']);
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
        });
  }
}

