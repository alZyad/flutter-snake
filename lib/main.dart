import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const numberOfCubesInWidth = 20;

class _MyHomePageState extends State<MyHomePage> {
  late final width = MediaQuery.of(context).size.width;
  late final cubeSize = width / numberOfCubesInWidth;
  late final numberOfCubesInHeight =
      (MediaQuery.of(context).size.height / cubeSize).round() - 10;
  late final totalNumberOfCubes =
      (numberOfCubesInHeight * numberOfCubesInWidth);

  // late final initialPosition = numberOfCubesInWidth * numberOfCubesInHeight + (numberOfCubesInWidth/2).round();
  static List<int> snakePosition = [0,20,40,60,80];
  late int food = Random().nextInt(totalNumberOfCubes);
  var isPlaying = false;

  Future<void> startGame() async {
    while (isPlaying) {
      await Future.delayed(const Duration(milliseconds: 100), () {
          updateSnake();
      });
    }
  } 
  void updateSnake() {
    final tail = snakePosition[snakePosition.length-1];
    for (var i = 0; i<snakePosition.length; i++) {
      setState(() {
        snakePosition[i]=snakePosition[i]+numberOfCubesInWidth;  
      });
    
      // ignore: avoid_print
      print(snakePosition);
    }
    snakePosition=snakePosition+[tail];

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(!isPlaying){
            setState(() {
              isPlaying = true;  
            });
            startGame();
          } else {
            setState(() {
              isPlaying = false;  
            });
          }
        },
        tooltip: 'Start the game',
        child: Container(color: Colors.yellow,),
      ),
      backgroundColor: Colors.black,
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: numberOfCubesInWidth,),
        itemBuilder: (BuildContext context, int index) {
          final colorGrid = Colors.grey[900];
          final colorSnake = Colors.white;
          final colorFood = Colors.green;
          var couleur = (snakePosition.contains(index)) ? colorSnake : (index==food? colorFood : colorGrid );
          return Container(
            padding: const EdgeInsets.all(2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(color: couleur),
            ),
          );
        },
        physics: const NeverScrollableScrollPhysics(),
        itemCount: totalNumberOfCubes,
      ),
    );
  }

}
