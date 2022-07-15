import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyDatabasePage extends StatefulWidget {
  const MyDatabasePage({Key? key, required this.title}) : super(key: key);//constructor
  final String title; //attribute

  @override
  State<MyDatabasePage> createState() => _MyDatabaseState();
}

class _MyDatabaseState extends State<MyDatabasePage> {  //home screen actions
  TextEditingController colorController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController labelController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {  //entire UI
    return Scaffold(    //default UI
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  //alignment
          children: <Widget>[
            TextField(
                controller: colorController,
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Color',
                )
            ),

            TextField(
                controller: descriptionController,
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                )
            ),

            TextField(
                controller: labelController,
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Label',
                )
            ),

            TextField(
                controller: nameController,
                obscureText: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                )
            ),

          ///replaceAll(new RegExp(r"\s+"), "");

            ElevatedButton(
                onPressed: (){
                  FirebaseFirestore.instance.collection("ingredients").add(
                    {
                      "color": colorController.text,
                      "description": descriptionController.text,
                      "label": labelController.text,
                      "name": nameController.text,
                      //"lowercaseName": nameController.text.replaceAll(new RegExp(r"/-|\s/g"), "").toLowerCase(),
                    "lowercaseName": nameController.text.replaceAll("-", "").replaceAll(new RegExp(r"\s+"), "").toLowerCase(),
                    }).then((value) {
                      print("Successfully added ingredient");
                    }).catchError((error){
                      print("Fail to add ingredient");
                      print(error);
                  });
                },
                child: Text("Add Ingredient")
            ),
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


          ],
        ),
      ),
    );
  }
}