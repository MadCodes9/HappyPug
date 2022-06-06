import 'package:flutter/material.dart';
import 'package:happy_pug/another_page.dart';

class MySecondPage extends StatefulWidget {
  const MySecondPage({Key? key, required this.title}) : super(key: key);//constructor
  final String title; //attribute

  @override
  State<MySecondPage> createState() => _MySecondPageState();
}

class _MySecondPageState extends State<MySecondPage> {  //home screen actions
  int _counter = 0;

  void _incrementCounter() {
    setState(() {

      _counter++;
      if (_counter > 10){
        _counter = 0;
      }
      print("The counter has been increased to " + _counter.toString());//debug
    });
    Navigator.push( //change from one screen to another
      context,
      MaterialPageRoute(builder: (context) => const MyThirdPage(title: 'My Page No.3')),
    );
    print("The counter has been increased to " + _counter.toString());//debug
  }

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
            const Text(
                'This is another text - Screen No.2'
            ),
            const Text(
                'App Logo - Screen No. 2'),
            const Text(
              'You have clicked the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4, //style of text
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton( //part of Scaffold
        onPressed: _incrementCounter,
        backgroundColor: Colors.deepOrange,
        tooltip: 'Increment',
        child: const Icon(Icons.add), //icon symbol
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}