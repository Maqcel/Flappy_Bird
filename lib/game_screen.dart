import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flappy/score_widget.dart';
import 'package:flutter/material.dart';

import 'flappy.dart';
import 'obstacle.dart';

class GameScreen extends StatefulWidget {
  final double gravity = -4.9;
  final double acceleration = 3.0;
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  //? Keys for collisions
  GlobalKey _bird = new GlobalKey();
  GlobalKey _firstObstacleUp = new GlobalKey();
  GlobalKey _firstObstacleDown = new GlobalKey();
  GlobalKey _secondObstacleUp = new GlobalKey();
  GlobalKey _secondObstacleDown = new GlobalKey();

  //? Obstacle flags
  static double obstacleUpOffset = 1.1;
  static double obstacleDownOffset = -1.1;
  static double obstacleOffset = 1.5;
  static double newObstacleOffset = 3.5;
  static double firstObstacleX = 1.6;
  static double secondObstacleX = firstObstacleX + obstacleOffset;
  static Random obstacleRandomize = new Random();
  int firstObstacleSize = obstacleRandomize.nextInt(6) * 2;
  int secondObstacleSize = obstacleRandomize.nextInt(6) * 2;

  //? Bird flags
  static double birdYAxis = 0;
  double timePassed = 0;
  double currentHeight = 0;
  double initialHeight = birdYAxis;

  //? Game flags
  bool gameHasStarted = false;
  static int currentScore = 0;
  static int highestScore = 0;
  bool shouldAddFirst = true;
  bool shouldAddSecond = true;

  List<double> obstacleSizes = [
    //? 0 up/down
    150.0,
    150.0,
    //? 2 up/down
    80.0,
    320.0,
    //? 4 up/down
    80.0,
    320.0,
    //? 6 up/down
    320.0,
    80.0,
    //? 8 up/down
    180.0,
    80.0,
    //? 10 up/down
    170.0,
    170.0,
  ];

  bool _checkCollisions(
      {required GlobalKey upObstacle, required GlobalKey downObstacle}) {
    bool collisionUp = false;
    bool collisionDown = false;

    //? Get all the widgets
    RenderBox bird = _bird.currentContext!.findRenderObject() as RenderBox;
    RenderBox obstacleUp =
        upObstacle.currentContext!.findRenderObject() as RenderBox;
    RenderBox obstacleDown =
        downObstacle.currentContext!.findRenderObject() as RenderBox;

    //? Get all the widgets sizes
    final Size birdSize = bird.size;
    late Size obstacleUpSize;
    late Size obstacleDownSize;
    obstacleUp.visitChildren((child) {
      RenderBox convert = child as RenderBox;
      obstacleUpSize = convert.size;
    });
    obstacleDown.visitChildren((child) {
      RenderBox convert = child as RenderBox;
      obstacleDownSize = convert.size;
    });

    //? Get all positions
    late Offset obstacleUpPosition;
    late Offset obstacleDownPosition;
    final Offset birdPosition = bird.localToGlobal(Offset.zero);
    obstacleUp.visitChildren((child) {
      RenderBox convert = child as RenderBox;
      obstacleUpPosition = convert.localToGlobal(Offset.zero);
    });
    obstacleDown.visitChildren((child) {
      RenderBox convert = child as RenderBox;
      obstacleDownPosition = convert.localToGlobal(Offset.zero);
    });

    //? Check upper obstacle
    collisionUp =
        (birdPosition.dx < obstacleUpPosition.dx + obstacleUpSize.width &&
            birdPosition.dx + birdSize.width > obstacleUpPosition.dx &&
            birdPosition.dy < obstacleUpPosition.dy + obstacleUpSize.height &&
            birdPosition.dy + birdSize.height > obstacleUpPosition.dy);
    collisionDown = (birdPosition.dx <
            obstacleDownPosition.dx + obstacleDownSize.width &&
        birdPosition.dx + birdSize.width > obstacleDownPosition.dx &&
        birdPosition.dy < obstacleDownPosition.dy + obstacleDownSize.height &&
        birdPosition.dy + birdSize.height > obstacleDownPosition.dy);
    return collisionUp || collisionDown;
  }

  void jump() {
    if (gameHasStarted)
      setState(() {
        timePassed = 0;
        initialHeight = birdYAxis;
      });
  }

  void lost() async {
    gameHasStarted = false;
    timePassed = 0;
    initialHeight = 0;
    firstObstacleX = 0.7;
    secondObstacleX = firstObstacleX + obstacleOffset;
    birdYAxis = 0;
    if (currentScore > highestScore) highestScore = currentScore;
    shouldAddFirst = true;
    shouldAddSecond = true;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('You lost!'),
        content: Text(
            'Collisions happens, better luck next Time!\nYour score: $currentScore'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Try Again!'),
          )
        ],
      ),
    );
    currentScore = 0;
  }

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(
      Duration(milliseconds: 50),
      (timer) {
        //! Up down movement
        timePassed += 0.035;
        currentHeight = widget.gravity * pow(timePassed, 2) +
            widget.acceleration * timePassed;

        //! check if bird hit the ground od celling
        if (birdYAxis > 1.2 || birdYAxis < -1.2) {
          timer.cancel();
          lost();
        }

        // //! Add score
        // if (firstObstacleX <= 0.2 && firstObstacleX >= -0.2 && shouldAddFirst) {
        //   setState(() {
        // currentScore++;
        // shouldAddFirst = false;
        //   });
        // }
        // if (secondObstacleX <= 0.1 &&
        //     secondObstacleX >= -0.1 &&
        //     shouldAddSecond) {
        //   setState(() {
        //     currentScore++;
        //     shouldAddSecond = false;
        //   });
        // }

        //! Check collisions 1
        if (firstObstacleX <= 0.15 && firstObstacleX >= -0.15) {
          setState(() {
            if (_checkCollisions(
              upObstacle: _firstObstacleUp,
              downObstacle: _firstObstacleDown,
            )) {
              timer.cancel();
              lost();
            } else {
              if (firstObstacleX <= 0.0) {
                currentScore++;
                shouldAddFirst = false;
              }
            }
          });
        }
        //! Check collisions 2
        if (secondObstacleX <= 0.15 && secondObstacleX >= -0.15) {
          setState(() {
            if (_checkCollisions(
              upObstacle: _secondObstacleUp,
              downObstacle: _secondObstacleDown,
            )) {
              timer.cancel();
              lost();
            } else {
              if (secondObstacleX <= 0.0) {
                currentScore++;
                shouldAddSecond = false;
              }
            }
          });
        }

        //! Update UI bird Y cord obstacles X pos regenerate new obstacle
        setState(() {
          birdYAxis = initialHeight - currentHeight;
          if (firstObstacleX < -1.4) {
            firstObstacleX += newObstacleOffset;
            firstObstacleSize = obstacleRandomize.nextInt(6) * 2;
            shouldAddFirst = true;
          } else {
            firstObstacleX -= 0.03;
          }
          if (secondObstacleX < -1.4) {
            secondObstacleX += newObstacleOffset;
            secondObstacleSize = obstacleRandomize.nextInt(6) * 2;
            shouldAddSecond = true;
          } else {
            secondObstacleX -= 0.03;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !gameHasStarted ? startGame : jump,
      child: Scaffold(
        body: Center(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: [
                Expanded(
                  flex: 8,
                  child: Container(
                    color: Colors.blue,
                    child: Stack(
                      children: [
                        AnimatedContainer(
                          alignment: Alignment(0.0, birdYAxis),
                          child: Flappy(key: _bird),
                          duration: Duration(milliseconds: 0),
                        ),
                        Container(
                          child: !gameHasStarted
                              ? Text(
                                  'TAP TO PLAY',
                                  style: TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.w500),
                                )
                              : Text(''),
                          alignment: Alignment(0, -0.4),
                        ),
                        Obstacle(
                          size: obstacleSizes.elementAt(firstObstacleSize),
                          firstObstacleX: firstObstacleX,
                          intentOffset: obstacleDownOffset,
                          key: _firstObstacleDown,
                        ),
                        Obstacle(
                          size: obstacleSizes.elementAt(firstObstacleSize + 1),
                          firstObstacleX: firstObstacleX,
                          intentOffset: obstacleUpOffset,
                          key: _firstObstacleUp,
                        ),
                        Obstacle(
                          size: obstacleSizes.elementAt(secondObstacleSize),
                          firstObstacleX: secondObstacleX,
                          intentOffset: obstacleDownOffset,
                          key: _secondObstacleDown,
                        ),
                        Obstacle(
                          size: obstacleSizes.elementAt(secondObstacleSize + 1),
                          firstObstacleX: secondObstacleX,
                          intentOffset: obstacleUpOffset,
                          key: _secondObstacleUp,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 15.0,
                  color: Colors.green,
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    color: Colors.brown[800],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ScoreWidget(score: currentScore, label: 'Score'),
                        ScoreWidget(score: highestScore, label: 'Best'),
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
