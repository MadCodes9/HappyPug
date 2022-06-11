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
            Container(
              child: Image(
                height: 300,
                width: 400,
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
              width: 350,
              height: 60,
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
              width: 350,
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