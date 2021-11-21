// ignore_for_file: avoid_print

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
  late bool isPaused = false;
  late int score = 0;
  late int highestScore = 0;
  late int turns = 0;

  void initGame() {
    snakePosition = [0, 20, 40, 60, 80];
    newDirection = 'down';
    direction = 'down';
    food = randomFood(totalNumberOfCubes);
    isPlaying = false;
    isPaused = false;
    score = 0;
    turns = 0;
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
    print({"gameOver", snakePosition, "direction", direction, "newDirection", newDirection});
    setState(() {
      initGame();
    });
    print({"gameOver over", snakePosition, "direction", direction, "newDirection", newDirection});
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

  bool checkHitWall(snakeHead, direction) {
    print({"checkHitWall method: ", snakePosition, "direction", direction, "newDirection", newDirection});
    bool hitWall;
    switch (direction) {
      case 'up':
        hitWall = snakeHead < numberOfCubesInWidth ? true : false;
        return hitWall;
      case 'down':
        hitWall = snakeHead > (totalNumberOfCubes-numberOfCubesInWidth) ? true : false;
        return hitWall;
      case 'left':
        hitWall = (snakeHead % numberOfCubesInWidth) == 0 ? true : false;
        return hitWall;
      case 'right':
        hitWall = (snakeHead % numberOfCubesInWidth) == (numberOfCubesInWidth - 1) ? true : false;
        return hitWall;
      default:
        hitWall = false;
        return hitWall;
    }
  }

  void updateSnake(round) {
    print({snakePosition, "direction", direction, "newDirection: ", newDirection});
    final tail = snakePosition[0];
    // Hit Top Wall
    if(checkHitWall(snakePosition.last, newDirection)){
      print({"we've hit the wall", checkHitWall(snakePosition.last, newDirection), newDirection});
      gameOver();
      return;
    }
    setState(() {
      if(direction==oppositeDirection(newDirection)){
        moveSnake(snakePosition, direction);
      } else {
        moveSnake(snakePosition, newDirection);
        direction = newDirection;
      }
      turns += 1;
      score = turns + snakePosition.length * 10;
      score > highestScore ? highestScore = score : null;
    });
    if (snakePosition.contains(food)) {
      snakePosition.insert(0, tail);
      food = randomFood(totalNumberOfCubes);
    }
    bool biteTail = (snakePosition.length - snakePosition.toSet().length) > 0;
    if (biteTail) {
      gameOver();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GestureDetector(
          onVerticalDragUpdate: (detail) {
            if (detail.delta.dy > 0 && direction != 'up') {
              newDirection = 'down';
            } else if (detail.delta.dy < 0 && direction != 'down') {
              newDirection = 'up';
            }
          },
          onHorizontalDragUpdate: (detail) {
            if (detail.delta.dx > 0 && direction != 'left') {
              newDirection = 'right';
            } else if (detail.delta.dx < 0 && direction != 'right') {
              newDirection = 'left';
            }
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
                    final colorSnakeHead = Colors.grey[350];
                    const colorSnakeBody = Colors.white;
                    const colorFood = Colors.green;
                    var couleur = (snakePosition.contains(index))
                        ? (index == snakePosition.last ? colorSnakeHead: colorSnakeBody)
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
                    children: [
                      Expanded(
                        child: Text(
                          'Highest score: $highestScore',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Score: $score',
                          style: const TextStyle(color: Colors.white),
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
                              print({"starting", snakePosition, "direction:", direction, "newDirection", newDirection});
                              startGame();
                            } else {
                              print({"stopping", snakePosition, "direction:", direction, "newDirection", newDirection});
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
      ),
    );
  }
}
