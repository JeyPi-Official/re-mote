// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:face_net_authentication/LEDS_FOCOS/normal/foco_normal.dart';
import 'package:face_net_authentication/menu/menu_opciones_page.dart';
import 'package:face_net_authentication/pages/servo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:face_net_authentication/constants/globals.dart' as globals;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: BluetoothLedControlScreen(),
  ));
}

class BluetoothLedControlScreen extends StatefulWidget {
  const BluetoothLedControlScreen({super.key});

  @override
  _BluetoothLedControlScreenState createState() =>
      _BluetoothLedControlScreenState();
}

class _BluetoothLedControlScreenState extends State<BluetoothLedControlScreen>
    with SingleTickerProviderStateMixin {
  BluetoothConnection? connection;
  bool isConnected = false;
  late AnimationController _controller;
  BluetoothDevice? selectedDevice;
  List<BluetoothDevice> devicesList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    if (isConnected) {
      connection?.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    var status = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location
    ].request();

    if (status[Permission.bluetooth]!.isGranted &&
        status[Permission.bluetoothConnect]!.isGranted &&
        status[Permission.bluetoothScan]!.isGranted &&
        status[Permission.location]!.isGranted) {
      _getBondedDevices();
    } else {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Permisos Requeridos',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Para utilizar esta aplicación, necesita conceder los permisos de Bluetooth y localización.',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }

  Future<void> _getBondedDevices() async {
    try {
      List<BluetoothDevice> devices =
          await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {
        devicesList = devices;
        isLoading = false;
      });
    } catch (e) {
      // Handle the error, possibly by showing a message to the user
      print("Error getting bonded devices: $e");
    }
  }

  Future<void> _connectToBluetoothDevice(BluetoothDevice device) async {
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        isConnected = true;
        globals.btled_state = true;
      });

      connection?.input?.listen(null).onDone(() {
        setState(() {
          isConnected = false;
          globals.btled_state = false;
        });
      });
    } catch (e) {
      // Handle connection error
      setState(() {
        isConnected = false;
        globals.btled_state = false;
      });
    }
  }

  void _sendColorToBluetoothDevice(Color color) {
    if (isConnected) {
      connection?.output
          .add(ascii.encode('R${color.red}G${color.green}B${color.blue}\n'));
      print('Red: ${color.red}, Green: ${color.green}, Blue: ${color.blue}');
    } else {
      _showNotConnectedDialog();
    }
  }

  void _showNotConnectedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Dispositivo no conectado',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Debe conectar un dispositivo Bluetooth antes de enviar un color.',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 3, 76, 136),
        foregroundColor: Colors.white,
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'FiraSans',
            color: Colors.white,
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
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 3, 76, 136),
              ),
            ),
            ListTile(
              title: Text(
                'Board',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'FiraSans',
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SensorDataScreen(),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                'Wifi Led',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'FiraSans',
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NormalLedScreen(),
                  ),
                );
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
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Led Bluetooth',
                style: TextStyle(
                    fontFamily: 'FiraSans',
                    color: Color.fromARGB(255, 3, 76, 136),
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 50),
              isLoading
                  ? const CircularProgressIndicator()
                  : DropdownButton<BluetoothDevice>(
                      value: selectedDevice,
                      hint: const Text(
                        "Selecciona un dispositivo",
                        style: TextStyle(
                            color: Color.fromARGB(255, 3, 76, 136),
                            fontSize: 20,
                            fontFamily: 'FiraSans',
                            fontWeight: FontWeight.normal),
                      ),
                      items: devicesList
                          .map(
                            (device) => DropdownMenuItem(
                              value: device,
                              child: Text(
                                device.name ?? "",
                                style: const TextStyle(
                                  fontFamily: 'FiraSans',
                                  color: Color.fromARGB(255, 3, 76, 136),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (device) {
                        setState(
                          () {
                            selectedDevice = device;
                          },
                        );
                        if (device != null) {
                          _connectToBluetoothDevice(device);
                        }
                      },
                    ),
              const SizedBox(height: 50),
              Divider(),
              const SizedBox(height: 50),
              const Text(
                'Cambia el color',
                style: TextStyle(
                  fontFamily: 'FiraSans',
                  color: Color.fromARGB(255, 3, 76, 136),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(200),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 255, 255, 255)
                          .withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: CircleColorPicker(
                  size: const Size(400.0, 400.0),
                  strokeWidth: 10,
                  onChanged: (Color color) {
                    _sendColorToBluetoothDevice(color);
                  },
                ),
              ),
              const SizedBox(height: 50),
              Divider(),
              const SizedBox(height: 100),
              Text(
                isConnected ? "Conectado" : "Desconectado",
                style: TextStyle(
                  color: isConnected
                      ? Color.fromARGB(255, 3, 76, 136)
                      : const Color.fromARGB(255, 255, 17, 0),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'FiraSans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text(
    //       'LED con Bluetooth',
    //       style: TextStyle(color: Colors.white),
    //     ),
    //     backgroundColor: const Color.fromARGB(255, 0, 0, 0),
    //     iconTheme: const IconThemeData(color: Colors.white),
    //   ),
    //   body: AnimatedBuilder(
    //     animation: _controller,
    //     builder: (context, child) {
    //       return Container(
    //         decoration: const BoxDecoration(
    //           gradient: LinearGradient(
    //             begin: Alignment.topLeft,
    //             end: Alignment.bottomRight,
    //             colors: [
    //               Color.fromARGB(255, 13, 0, 126),
    //               Color.fromARGB(255, 102, 0, 118),
    //             ],
    //           ),
    //         ),
    //         child: Stack(
    //           children: [
    //             StarAnimation(animation: _controller),
    // Center(
    //   child: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: <Widget>[
    //       isLoading
    //           ? const CircularProgressIndicator()
    //           : DropdownButton<BluetoothDevice>(
    //               value: selectedDevice,
    //               hint: const Text("Selecciona un dispositivo",
    //                   style: TextStyle(color: Colors.white)),
    //               items: devicesList
    //                   .map((device) => DropdownMenuItem(
    //                         value: device,
    //                         child: Text(
    //                           device.name ?? "",
    //                           style: const TextStyle(
    //                               color: Color.fromARGB(
    //                                   255, 119, 119, 119)),
    //                         ),
    //                       ))
    //                   .toList(),
    //               onChanged: (device) {
    //                 setState(() {
    //                   selectedDevice = device;
    //                 });
    //                 if (device != null) {
    //                   _connectToBluetoothDevice(device);
    //                 }
    //               },
    //             ),
    //       const SizedBox(height: 60),
    //       const Text(
    //         'Selecciona un color para el LED:',
    //         style: TextStyle(color: Colors.white, fontSize: 20),
    //       ),
    //       const SizedBox(height: 50),
    //       Container(
    //         decoration: BoxDecoration(
    //           borderRadius: BorderRadius.circular(200),
    //           boxShadow: [
    //             BoxShadow(
    //               color: const Color.fromARGB(255, 255, 255, 255)
    //                   .withOpacity(0.5),
    //               spreadRadius: 3,
    //               blurRadius: 7,
    //               offset: const Offset(0, 3),
    //             ),
    //           ],
    //         ),
    //         child: CircleColorPicker(
    //           size: const Size(400.0, 400.0),
    //           strokeWidth: 10,
    //           onChanged: (Color color) {
    //             _sendColorToBluetoothDevice(color);
    //           },
    //         ),
    //       ),
    //       const SizedBox(height: 20),
    //       Text(
    //         isConnected ? "Conectado" : "Desconectado",
    //         style: TextStyle(
    //           color: isConnected ? Colors.green : Colors.red,
    //           fontSize: 18,
    //           fontWeight: FontWeight.bold,
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    //           ],
    //         ),
    //       );
    //     },
    //   ),
    // );
  }
}

class StarAnimation extends StatelessWidget {
  final Animation<double> animation;

  const StarAnimation({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: StarrySkyPainter(animation.value),
      size: Size.infinite,
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
      final double x1 = center.dx +
          halfSize * cos((rotation - halfStep + i * angleStep) * degToRad);
      final double y1 = center.dy +
          halfSize * sin((rotation - halfStep + i * angleStep) * degToRad);

      path.lineTo(x1, y1);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
