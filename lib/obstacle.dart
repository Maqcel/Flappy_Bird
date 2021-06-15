import 'package:flutter/material.dart';

class Obstacle extends StatelessWidget {
  final double size;
  final double firstObstacleX;
  final double intentOffset;
  final Key key;
  const Obstacle({
    required this.size,
    required this.firstObstacleX,
    required this.intentOffset,
    required this.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      alignment: Alignment(firstObstacleX, intentOffset),
      duration: Duration(milliseconds: 0),
      child: Container(
        height: size,
        width: 80.0,
        decoration: BoxDecoration(
          color: Colors.green[600],
          border: Border.all(
            color: Color.fromRGBO(9, 66, 1, 1.0),
            width: 3.0,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
