import 'package:flutter/material.dart';

class Flappy extends StatelessWidget {
  final Key key;
  const Flappy({required this.key});
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/flappy.png',
      height: 55.0,
      width: 55.0,
      fit: BoxFit.contain,
    );
  }
}
