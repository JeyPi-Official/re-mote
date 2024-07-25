// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:face_net_authentication/LEDS_FOCOS/bluetooth/bluetooth_page.dart';
import 'package:face_net_authentication/pages/servo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NormalLedScreen extends StatefulWidget {
  const NormalLedScreen({super.key});

  @override
  _NormalLedScreenState createState() => _NormalLedScreenState();
}

class _NormalLedScreenState extends State<NormalLedScreen> {
  final String _esp8266Url = 'http://192.168.0.163';
  bool _isLedOn = false;

  // Función para verificar el estado actual del LED normal
  Future<void> _checkNormalLedState() async {
    try {
      final response = await http.get(Uri.parse('$_esp8266Url/normalledstate'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _isLedOn = data['isOn'];
        });
      } else {
        throw Exception('Failed to load LED state');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Función para enviar el estado del LED normal al ESP8266
  Future<void> _sendNormalLedStateToEsp8266(bool isOn) async {
    final state = isOn ? 1 : 0;
    await http.get(Uri.parse('$_esp8266Url/normalled?state=$state'));
  }

  @override
  void initState() {
    super.initState();
    _checkNormalLedState(); // Verificar el estado al inicio
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text(
    //       'Foco Normal',
    //       style: TextStyle(color: Colors.white),
    //     ),
    //     backgroundColor: Colors.black,
    //     iconTheme: const IconThemeData(color: Colors.white),
    //   ),
    //   body: Stack(
    //     children: [
    //       // Fondo animado con estrellas
    //       const AnimatedBackground(),
    //       // Contenido principal envuelto en un cuadro con opacidad
    //       Center(
    //         child: Container(
    //           width: 300, // Ancho del contenedor
    //           height: 300, // Largo del contenedor
    //           padding: const EdgeInsets.all(20),
    //           decoration: BoxDecoration(
    //             color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2), // Opacidad de la caja
    //             borderRadius: BorderRadius.circular(20), // Borde redondeado
    //             boxShadow: [
    //               BoxShadow(
    //                 color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5), // Opacidad de la sombra
    //                 spreadRadius: 5,
    //                 blurRadius: 7,
    //                 offset: const Offset(0, 3), // Desplazamiento de la sombra
    //               ),
    //             ],
    //           ),
    //           child: Column(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               Icon(
    //                 Icons.lightbulb_outline,
    //                 size: 120,
    //                 color: _isLedOn ? Colors.yellow : Colors.white,
    //               ),
    //               const SizedBox(height: 20),
    //               const Text(
    //                 'Control del Foco normal:',
    //                 style: TextStyle(
    //                   color: Colors.white,
    //                   fontSize: 24,
    //                   fontWeight: FontWeight.bold,
    //                 ),
    //               ),
    //               const SizedBox(height: 20),
    //               Switch(
    //                 value: _isLedOn,
    //                 onChanged: (bool newValue) {
    //                   setState(() {
    //                     _isLedOn = newValue;
    //                   });
    //                   _sendNormalLedStateToEsp8266(newValue);
    //                 },
    //                 activeColor: Colors.yellow,
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 3, 76, 136),
        foregroundColor: Colors.white,
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontFamily: 'FiraSans',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: SizedBox.expand(
                child: Align(
                  child: Text(
                    'Menú',
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'FiraSans',
                        color: Colors.white),
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 3, 76, 136),
              ),
            ),
            ListTile(
              title: Text('Led Bluetooth'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const BluetoothLedControlScreen()));
              },
            ),
            Divider(),
            ListTile(
              title: Text('Servomotor'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServoControlScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 200,
                color:
                    _isLedOn ? Colors.yellow : Color.fromARGB(255, 3, 76, 136),
              ),
              const SizedBox(height: 20),
              const Text(
                'Control del Foco Wifi:',
                style: TextStyle(
                    color: Color.fromARGB(255, 3, 76, 136),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'FiraSans'),
              ),
              const SizedBox(height: 50),
              Transform.scale(
                scale: 2,
                child: Switch(
                  value: _isLedOn,
                  onChanged: (bool newValue) {
                    setState(
                      () {
                        _isLedOn = newValue;
                      },
                    );
                    _sendNormalLedStateToEsp8266(newValue);
                  },
                  activeColor: Colors.yellow,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Fondo animado con estrellas que ocupa toda la pantalla
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
      duration: const Duration(seconds: 1), // Duración más lenta
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
              // Estrellas aquí
              StarAnimation(animation: _animation),
            ],
          ),
        );
      },
    );
  }
}

// Animación de estrellas que se desplaza por toda la pantalla
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
          child: Container(),
        );
      },
    );
  }
}

// Pintor personalizado para las estrellas
class StarrySkyPainter extends CustomPainter {
  final double animationValue;

  StarrySkyPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const int starCount = 100; // Aumentado el número de estrellas

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
