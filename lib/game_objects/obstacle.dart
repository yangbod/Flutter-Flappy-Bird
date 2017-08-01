import 'package:flutter/material.dart';

class Obstacle extends StatefulWidget {
  @override
  ObstacleState createState() => new ObstacleState();
}

class ObstacleState extends State<Obstacle> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(color: Colors.black),
      width: 50.0,
      height: 400.0,
    );
  }
}