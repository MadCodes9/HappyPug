import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({Key? key, required this.title}) : super(key: key);//constructor
  final String title; //attribute

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {  //home screen actions
TextEditingController usernameController = TextEditingController();
TextEditingController passwordController = TextEditingController();

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
            // Expanded( //expand layout giving rest of layout minimum space
            //   flex: 25,  //percentage of how much layout is expanded
            //     child:Text("Title 1"),
            // ),
            // Expanded(
            //   flex: 12, //percentage of weight to the widget
            //     child: Text("Hello")),
            Container(
              child: Image(
                height: 300,
                width: 300,
                image: NetworkImage('https://i.pinimg.com/originals/53/cb/23/53cb231f4c04ae30a04a6e292eb2a48c.jpg')
              ),
            ),
           // Expanded(  //maximum space you can use
           //   child:  TextField(
           //     controller: usernameController,
           //     obscureText: false,
           //     decoration: InputDecoration(
           //       border: OutlineInputBorder(),
           //       labelText: 'Username',
           //     )
           // )),
           //
            Container(
              //alignment: Alignment.centerLeft,
              width: 360,
              //margin: EdgeInsets.all(10),
             // margin: EdgeInsets.only(top: 30, bottom: 20),
              child: TextField(
                  controller: usernameController,
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                  )
              )
            ),
            Container(
              //alignment: Alignment.center,
              width: 360,
              child:  TextField(
                  controller: passwordController,
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  )
              ),
            ),

            ElevatedButton(
                onPressed: (){
                  FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: usernameController.text, password: passwordController.text)
                      .then((value) {
                        print("Successfully login!");
                        }).catchError((error) {
                        print("Failed to login");
                        print(error.toString());
                        });
                },
                child: Text("Login")
            ),

            ElevatedButton(
                onPressed: () {
                  //sign up user and save to Firebase Auth service
                  FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: usernameController.text,
                      password: passwordController.text)
                      .then((value) {
                    print("Successfully sign up the user!");
                  }).catchError((error) {
                    print("Failed to sign up user");
                    print(error.toString());
                  });
                },

                child: Text("Signup")
            )

          ],
        ),
      ),
    );
  }
}