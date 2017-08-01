import 'package:flutter/material.dart';

class Character extends StatefulWidget {

  Character({ Key key }) : super(key: key);

  @override
  CharacterState createState() => new CharacterState();
}

class CharacterState extends State<Character> with TickerProviderStateMixin {

  AnimationController _controller;
  Animation<FractionalOffset> _charPos;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _charPos = new FractionalOffsetTween(
      begin: const FractionalOffset(0.0, 0.0),
      end: const FractionalOffset(0.0, -0.3),
    ).animate(new CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    )..addStatusListener((AnimationStatus status) {
      if ( status == AnimationStatus.completed ) {
        _controller.reverse(from: 1.0);
      }
    })
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void flap() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return new SlideTransition(
      child: new Center (
        child: new Container(
          width: 20.0,
          height: 20.0,
          decoration: new BoxDecoration(color: Colors.black),
        ),
      ),
      position: _charPos,
    );
  }
}