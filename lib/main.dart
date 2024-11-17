import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const FlappyButt());
}

class FlappyButt extends StatelessWidget {
  const FlappyButt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static double birdY = 0;
  double time = 0;
  double height = 0;
  double initialHeight = birdY;
  bool gameStarted = false;

  // Obstacle variables
  double barrierX = 1.5; // Initial position
  double barrierHeight = Random().nextDouble() * 0.6 + 0.4; // Random height

  // Score tracking
  int score = 0;

  // Buffer for collision sensitivity
  final double bufferMargin = 0.05;

  void jump() {
    setState(() {
      time = 0;
      initialHeight = birdY;
    });
  }

  void startGame() {
    gameStarted = true;
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      // Physics
      time += 0.02;
      height = -4.9 * time * time + 2.8 * time; // Gravity and initial velocity
      setState(() {
        birdY = initialHeight - height;
      });

      // Barrier movement
      setState(() {
        if (barrierX < -1.5) {
          barrierX = 1.5;
          barrierHeight = Random().nextDouble() * 0.6 + 0.2; // Randomize height
          score++; // Increment score when a barrier is passed
        } else {
          barrierX -= 0.015; // Barrier speed
        }
      });

      // Check for collision
      if (birdY > 1 ||
          birdY < -1 ||
          (barrierX < 0.25 &&
              barrierX > -0.25 &&
              (birdY < -1 + barrierHeight + bufferMargin ||
                  birdY > 1 - barrierHeight - bufferMargin))) {
        timer.cancel();
        gameStarted = false;
        _showGameOverDialog();
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ban thua roi!'),
          content: Text('Diem cua ban la: $score'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      birdY = 0;
      time = 0;
      initialHeight = birdY;
      barrierX = 1.5;
      barrierHeight = Random().nextDouble() * 0.6 + 0.2;
      gameStarted = false;
      score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: gameStarted ? jump : startGame,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  Container(
                    color: Colors.blue,
                  ),
                  AnimatedContainer(
                    alignment: Alignment(0, birdY),
                    duration: const Duration(milliseconds: 0),
                    child: const Bird(),
                  ),
                  AnimatedContainer(
                    alignment: Alignment(barrierX, 1),
                    duration: const Duration(milliseconds: 0),
                    child: Barrier(size: barrierHeight, isBottom: true),
                  ),
                  AnimatedContainer(
                    alignment: Alignment(barrierX, -1),
                    duration: const Duration(milliseconds: 0),
                    child: Barrier(size: 1 - barrierHeight, isBottom: false),
                  ),
                  Container(
                    alignment: const Alignment(0, -0.3),
                    child: gameStarted
                        ? const SizedBox.shrink()
                        : const Text(
                            'Nhan de bat dau',
                            style: TextStyle(fontSize: 30, color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
            Container(
              height: 15,
              color: Colors.green,
            ),
            Expanded(
              child: Container(
                color: Colors.brown,
                child: Center(
                  child: Text(
                    'So diem: $score',
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Bird extends StatelessWidget {
  const Bird({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        'assets/pelican.png',
        width: 40,
        height: 40,
      ),
    );
  }
}

class Barrier extends StatelessWidget {
  final double size;
  final bool isBottom;

  const Barrier({Key? key, required this.size, required this.isBottom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: MediaQuery.of(context).size.height * size / 2,
      decoration: BoxDecoration(
        color: Colors.green,
        border: Border.all(color: Colors.green[900]!, width: 10),
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
    );
  }
}
