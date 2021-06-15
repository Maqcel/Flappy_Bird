import 'package:flutter/material.dart';

class ScoreWidget extends StatelessWidget {
  final int score;
  final String label;

  const ScoreWidget({required this.score, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20.0),
        Text(
          score.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 35.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
