// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, unused_local_variable

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class LedScreen extends StatefulWidget {
  const LedScreen({super.key});

  @override
  _LedScreenState createState() => _LedScreenState();
}

class _LedScreenState extends State<LedScreen> {
  final String _esp8266Url = 'http://192.168.0.163'; // Cambia esta URL según sea necesario
  Color _currentColor = Colors.white;

  Future<void> _sendColorToEsp8266(Color color) async {
    final String hexColor = color.value.toRadixString(16).padLeft(8, '0');
    try {
      await http.get(Uri.parse(
          '$_esp8266Url/color?red=${color.red}&green=${color.green}&blue=${color.blue}'));
    } catch (e) {
      //print('Error al enviar color a ESP8266: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tira LED',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          const AnimatedBackground(),
          Center(
            child: Container(
              width: 350, // Ancho de la caja contenedora
              height: 600, // Largo de la caja contenedora
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2), // Opacidad de la caja
                borderRadius: BorderRadius.circular(20), // Borde redondeado
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5), // Opacidad de la sombra
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // Desplazamiento de la sombra
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Selecciona un color para la tira LED:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ColorPicker(
                    pickerColor: _currentColor,
                    onColorChanged: (Color color) {
                      setState(() {
                        _currentColor = color;
                      });
                    },
                    showLabel: true,
                    pickerAreaHeightPercent: 0.8,
                  ),
                  ElevatedButton(
                    onPressed: () => _sendColorToEsp8266(_currentColor),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Cambiar color',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
              Color.fromARGB(255, 13, 0, 126),
              Color.fromARGB(255, 102, 0, 118),
              ],
            ),
          ),
          child: Stack(
            children: [
              StarAnimation(animation: _animation),
            ],
          ),
        );
      },
    );
  }
}

class StarAnimation extends StatelessWidget {
  final Animation<double> animation;

  const StarAnimation({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: StarrySkyPainter(animation.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class StarrySkyPainter extends CustomPainter {
  final double animationValue;

  StarrySkyPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.fill;

    const int starCount = 100;

    final random = Random();

    for (int i = 0; i < starCount; i++) {
      final double starSize = 2.0 + random.nextDouble() * 3.0;
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final starOffset = Offset(x, y);
      final path = _createStarPath(starOffset, starSize);
      canvas.drawPath(path, paint);
    }
  }

  Path _createStarPath(Offset center, double size) {
    final Path path = Path();
    const double degToRad = pi / 180.0;
    const double rotation = 180.0;

    const double angleStep = 360 / 5;
    const double halfStep = angleStep / 2;

    final double halfSize = size / 2;

    final double x0 =
        center.dx + halfSize * cos((rotation - halfStep) * degToRad);
    final double y0 =
        center.dy + halfSize * sin((rotation - halfStep) * degToRad);
    path.moveTo(x0, y0);

    for (int i = 1; i <= 5; i++) {
      final double x = center.dx +
          halfSize * cos((rotation + angleStep * i - halfStep) * degToRad);
      final double y = center.dy +
          halfSize * sin((rotation + angleStep * i - halfStep) * degToRad);
      path.lineTo(x, y);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
