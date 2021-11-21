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
      title: 'Znake',
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
const numberOfCubesInHeight = 20;

class _MyHomePageState extends State<MyHomePage> {
  late final width = MediaQuery.of(context).size.width - 20;
  late final height = MediaQuery.of(context).size.height - 20;
  late final cubeSize =
      min(width / numberOfCubesInWidth, height / (numberOfCubesInHeight + 10));
  late final totalNumberOfCubes =
      (numberOfCubesInHeight * numberOfCubesInWidth);

  int randomFood(total) {
    food = Random().nextInt(total);
    while (snakePosition.contains(food)) {
      food = Random().nextInt(total);
    }
    return food;
  }

  // late final initialPosition = numberOfCubesInWidth * numberOfCubesInHeight + (numberOfCubesInWidth/2).round();
  late List<int> snakePosition = [0, 20, 40, 60, 80];
  late String direction = "down";
  late String newDirection = "down";  
  late int food = randomFood(totalNumberOfCubes);
  late bool isPlaying = false;
  late bool isPaused;

  void initGame() {
    snakePosition = [0, 20, 40, 60, 80];
    direction = 'down';
    food = randomFood(totalNumberOfCubes);
    isPlaying = false;
    isPaused = false;
  }

  Future<void> startGame() async {
    var round = 0;
    while (isPlaying && !isPaused) {
      round += 1;
      await Future.delayed(const Duration(milliseconds: 500), () {
        if (isPlaying && !isPaused) {
          updateSnake(round);
        }
      });
    }
  }

  void gameOver() {
    setState(() {
      initGame();
    });
  }

  void moveSnake(snakePosition, direction) {
    switch (direction) {
      case 'down':
        snakePosition.add(snakePosition.last + numberOfCubesInWidth);
        break;
      case 'up':
        snakePosition.add(snakePosition.last - numberOfCubesInWidth);
        break;
      case 'right':
        snakePosition.add(snakePosition.last + 1);
        break;
      case 'left':
        snakePosition.add(snakePosition.last - 1);
        break;
    }
    snakePosition.removeAt(0);
  }
  String oppositeDirection(direction) {
    switch (direction) {
      case 'up':
        return 'down';
      case 'down':
        return 'up';
      case 'left':
        return 'right';
      case 'right':
        return 'left';
      default:
        return 'down';
    }
  }
  void updateSnake(round) {
    final tail = snakePosition[snakePosition.length - 1];
    // ignore: avoid_print
    // print(snakePosition);
    setState(() {
      if(direction==oppositeDirection(newDirection)){
        moveSnake(snakePosition, direction);
      } else {
        moveSnake(snakePosition, newDirection);
        direction = newDirection;
      }
    });
    if (snakePosition.contains(food)) {
      snakePosition.insert(0, tail);
      food = randomFood(totalNumberOfCubes);
    }
    bool biteTail = (snakePosition.length - snakePosition.toSet().length) > 0;
    bool hitWall = false;
    for (var part in snakePosition) {
      hitWall = part < 1 || part > totalNumberOfCubes;
      if (hitWall) {
        break;
      }
    }
    print(round);
    print(direction);
    print(snakePosition);
    print(biteTail);
    if (biteTail) {
      gameOver();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onVerticalDragUpdate: (detail) {
          print({"vertical",detail.delta});
          if (detail.delta.dy > 0) {
            newDirection = 'down';
          } else if (detail.delta.dy < 0) {
            newDirection = 'up';
          }
        },
        onHorizontalDragUpdate: (detail) {
          print({"horizontal",detail.delta});
          if (detail.delta.dx > 0) {
            newDirection = 'right';
          } else if (detail.delta.dx < 0) {
            newDirection = 'left';
          }
          print(direction);
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            children: [
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: numberOfCubesInWidth,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final colorGrid = Colors.grey[900];
                  const colorSnake = Colors.white;
                  const colorFood = Colors.green;
                  var couleur = (snakePosition.contains(index))
                      ? colorSnake
                      : (index == food ? colorFood : colorGrid);
                  return Container(
                    width: cubeSize,
                    height: cubeSize,
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(color: couleur),
                    ),
                  );
                },
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalNumberOfCubes,
                shrinkWrap: true,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Expanded(
                      child: Text(
                        'Highest score',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Score: ',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            isPlaying ? Colors.red[600] : Colors.green,
                          ),
                          fixedSize: MaterialStateProperty.all<Size>(
                            const Size(150, 60),
                          ),
                          alignment: Alignment.center,
                        ),
                        onPressed: () {
                          if (!isPlaying) {
                            setState(() {
                              isPlaying = true;
                            });
                            startGame();
                          } else {
                            setState(() {
                              initGame();
                            });
                          }
                        },
                        child: SizedBox(
                          child: Text(
                            (isPlaying ? "Stop" : "Start"),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all<Size>(
                            const Size(150, 60),
                          ),
                          alignment: Alignment.center,
                          backgroundColor: MaterialStateProperty.all(
                            Colors.blue,
                          ),
                        ),
                        onPressed: () {
                          if (isPlaying) {
                            setState(() {
                              isPaused = !isPaused;
                              startGame();
                            });
                          }
                        },
                        child: SizedBox(
                          child: Text(
                            (!isPaused ? "Pause" : "Resume"),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
