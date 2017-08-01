import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';

import '../game_objects/char.dart';
import '../game_objects/obstacle.dart';

class GameScreen extends StatefulWidget {
  @override
  GameScreenState createState() => new GameScreenState();
}

class GameScreenState extends State<GameScreen> with TickerProviderStateMixin {

  //-- Character declarations --//

  static final GlobalKey<CharacterState> characterKey = new GlobalKey<CharacterState>();
  Character char;

  double bottom = 500.0;

  AnimationController _characterAnimationController;
  Animation<FractionalOffset> _characterPosition;
  //______________________________________________________________//

  //-- Obstacle declarations --//

  List<AnimationController> _controllers = new List();
  List<Animation<FractionalOffset>> _topPositions = new List();
  List<Animation<FractionalOffset>> _botPositions = new List();

  List<double> topBarHeights = new List();
  List<double> bottomBarHeights = new List();

  Animation<FractionalOffset> timer;

  Random rand = new Random();
  double topBarHeight;
  double botBarHeight;
  //______________________________________________________________//

  @override
  void initState() {
    super.initState();

    //-- Character animation handling --//

    char = new Character(key: characterKey);

    _characterAnimationController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _characterPosition = new FractionalOffsetTween(
      begin: const FractionalOffset(0.0, 0.0),
      end: const FractionalOffset(0.0, -10.0),
    ).animate(new CurvedAnimation(
      parent: _characterAnimationController,
      curve: Curves.easeOut,
      )..addStatusListener((AnimationStatus status) {
        if ( status == AnimationStatus.completed ) {
          _characterAnimationController.reverse(from: 1.0);
        }
      })
    );
    //______________________________________________________________//

    //-- Obstacle animation handling --//
    topBarHeight = - rand.nextDouble();
    botBarHeight = rand.nextDouble() * 2;

    for (int i = 0; i < 2; i++) {
      topBarHeights.add(topBarHeight = - rand.nextDouble());
      bottomBarHeights.add(botBarHeight = rand.nextDouble() * 2);
      if (bottomBarHeights[i] == 0)
        bottomBarHeights[i] = 1.0;
    }
    
    for (int i = 0; i < 4; i++) {
      _controllers.add(new AnimationController(
        vsync: this,
        duration: const Duration(seconds: 6),
      ));
    }
    _controllers.add(new AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    ));

    for (int i = 0; i < 2; i++) {
      _topPositions.add(
        new FractionalOffsetTween(
          begin: const FractionalOffset(0.2, 0.0),
          end: const FractionalOffset(-1.0, 0.0),
        ).animate(
          new CurvedAnimation(
            parent: _controllers[i],
            curve: Curves.linear,
          )..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              _controllers[i].forward(from: 0.0);
            } else if (status == AnimationStatus.forward) {
              this.setState(() {
                topBarHeights[i] = - rand.nextDouble();
              });
            }
          })
        )
      );

      _botPositions.add(
        new FractionalOffsetTween(
          begin: const FractionalOffset(0.2, 0.0),
          end: const FractionalOffset(-1.0, 0.0),
        ).animate(
          new CurvedAnimation(
            parent: _controllers[i+2],
            curve: Curves.linear,
          )..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              _controllers[i+2].forward(from: 0.0);
            } else if (status == AnimationStatus.forward) {
              this.setState(() {
                bottomBarHeights[i] = rand.nextDouble() + 2 / 2;
                if (bottomBarHeights[i] == 0.0) {
                  bottomBarHeights[i] = 1.0;
                }
              });
            }
          })
        )
      );
    }

    timer = new FractionalOffsetTween(
      begin: const FractionalOffset(0.2, 0.0),
      end: const FractionalOffset(-1.0, 0.0),
    ).animate(
      new CurvedAnimation(
        parent: _controllers[4],
        curve: Curves.linear,
      )..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _controllers[1].forward(from: 0.0);
          _controllers[3].forward(from: 0.0);
          this.setState(() {
            bottom = 0.0;
          });
        }
      })
    );

     _controllers[0].forward(from: 0.0);
     _controllers[2].forward(from: 0.0);
     _controllers[4].forward();
     //______________________________________________________________//
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    void flap() {
      this.setState(() {
        bottom = 250.0;
        new Timer(new Duration(milliseconds: 100), () => bottom = 0.0);
      });
      if (_characterAnimationController.isAnimating) {

        print(_characterAnimationController.value);
        _characterAnimationController.stop();
        _characterAnimationController.forward(from: 0.0);
      } else {
        _characterAnimationController.forward(from: 0.0);
      }
    }

    return new GestureDetector(
      onTap: () {
        flap();
      },
      child: new Container(
        decoration: new BoxDecoration(color: Colors.green),
        child: new Center(
          child: new Container(
            child: new Stack(
              children: <Widget>[
                new SlideTransition(
                  child: new Container(
                    alignment: new FractionalOffset(1.0, topBarHeights[0]),
                    child: new Obstacle(),
                  ),
                  position: _topPositions[0],
                ),
                new SlideTransition(
                  child: new Container(
                    alignment: new FractionalOffset(1.0, topBarHeights[1]),
                    child: new Obstacle(),
                  ),
                  position: _topPositions[1],
                ),
                new SlideTransition(
                  child: new Container(
                    alignment: new FractionalOffset(1.0, bottomBarHeights[0]),
                    child: new Obstacle(),
                  ),
                  position: _botPositions[0],
                ),
                new SlideTransition(
                  child: new Container(
                    alignment: new FractionalOffset(1.0, bottomBarHeights[1]),
                    child: new Obstacle(),
                  ),
                  position: _botPositions[1],
                ),
                new SlideTransition(
                  child: new Container(
                    alignment: new FractionalOffset(0.0, 0.0),
                  ),
                  position: timer,
                ),
                // new SlideTransition(
                //   child: new Container(
                //     child: char,
                //   ),
                //   position: _characterPosition,
                // )
                new AnimatedPositioned(
                  child: new Container(
                    child: char
                  ),
                  duration: new Duration(seconds: 1),
                  curve: Curves.easeIn,
                  bottom: bottom,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}