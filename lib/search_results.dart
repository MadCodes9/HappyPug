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
  Map<String, List<String>> results = {};
  List<String> keys = [];
  bool _isVisible = false;
  final Map<String,Color> btnColor = {};

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
                Icon(
                  Icons.check_rounded,
                  color: Colors.lightGreen,
                ),
                Expanded(
                  child: Text(
                    "${widget.numOfgreenIngred} Healthy",
                    style: TextStyle(color: Colors.black, fontSize: 15),
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
                    style: TextStyle(color: Colors.black, fontSize: 15),
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
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                  //flex: 0,
                ),
              ],
            ),

            Row(
              children: [
                ButtonTheme(
                  child: TextButton.icon(
                    label: Text("Overall", style: TextStyle(color: Colors.black,
                    fontSize: 15)),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey,
                    ),
                    onPressed: (){

                    },
                  ),
                ),

                ButtonTheme(
                  child: TextButton.icon(
                    label: Text("Ingredients", style: TextStyle(color: Colors.black,
                    fontSize: 15)),
                    onPressed: (){
                      setButtons();//Access widget attributes
                      showText(); //Controls visibility
                    },
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child:
                  Visibility( //show ingredients
                    visible: _isVisible,
                    child: Column(//dynamically display ingredients
                        children:
                        keys.map((String ingredient) => TextButton.icon(

                          onPressed: (){  //show description, rating
                            print(ingredient);
                            Text("Description ");
                            setButtonColor(ingredient);//dynamically set background color
                            print(results[ingredient]?.elementAt(0));},
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(btnColor[ingredient]),
                            fixedSize: MaterialStateProperty.all(Size.fromWidth(340)),
                          ),
                          label:
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              ingredient,
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                          icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black54
                          ),
                        )).toList()
                    ),
                  ),
                ),

            ),



            // Container(
            //   child:
            //   pressed1 ? null:null,
            // ),
            // Container(
            //   child: Column(
            //     children: [
            //       //Text("Ingredients Found: ${widget.foundIngred.keys}")
            //       pressed2 ? Column(
            //        children:
            //         keys.map((String data) => TextButton.icon(
            //             onPressed: (){print(data);},
            //             label: Text(data),
            //             icon: Icon(
            //               Icons.arrow_drop_down_circle_rounded,
            //               color: Colors.grey,
            //             ),
            //         )).toList(),):SizedBox()
            //     ]
            //   ),
            // ),

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

  void setButtons() {
      results = widget.foundIngred;
      keys = widget.foundIngred.keys.toList();
  }
  void setButtonColor(String ingredient){
    setState(() {
      if(results[ingredient]?.elementAt(1) == "green"){
        btnColor[ingredient] = Colors.green;
      }
      else if (results[ingredient]?.elementAt(1) == "yellow"){
        btnColor[ingredient] = Colors.yellow;
      }
      else if (results[ingredient]?.elementAt(1) == "red"){
        btnColor[ingredient] = Colors.red;
      }
      else{
        btnColor[ingredient] = Colors.lightBlueAccent;
      }
    });
  }
  void showText(){
    setState((){
      _isVisible = !_isVisible;
    });
  }
}

