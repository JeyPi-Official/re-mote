// import 'dart:io';

// import 'package:face_net_authentication/pages/widgets/app_button.dart';
// import 'package:flutter/material.dart';
// import 'home.dart';

// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
// import 'package:permission_handler/permission_handler.dart';

// class Profile extends StatelessWidget {
//   const Profile(this.username, {Key? key, required this.imagePath})
//       : super(key: key);
//   final String username;
//   final String imagePath;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Container(
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: Colors.black,
//                       image: DecorationImage(
//                         fit: BoxFit.cover,
//                         image: FileImage(File(imagePath)),
//                       ),
//                     ),
//                     margin: EdgeInsets.all(20),
//                     width: 50,
//                     height: 50,
//                   ),
//                   Text(
//                     'Hola ' + username + '!',
//                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
//                   ),
//                 ],
//               ),
//               Container(
//                 margin: EdgeInsets.all(20),
//                 padding: EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Color(0xFFFEFFC1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.warning_amber_outlined,
//                       size: 30,
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Text(
//                       '''¡Binvenido!''',
//                       style: TextStyle(fontSize: 16),
//                       textAlign: TextAlign.left,
//                     ),
//                   ],
//                 ),
//               ),
//               Spacer(),
//               AppButton(
//                 text: "Salir",
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => MyHomePage()),
//                   );
//                 },
//                 icon: Icon(
//                   Icons.logout,
//                   color: Colors.white,
//                 ),
//                 color: Color(0xFFFF6161),
//               ),
//               SizedBox(
//                 height: 20,
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: Profile(),
  ));
}

class Profile extends StatefulWidget {
  const Profile({
    super.key,
    /*required String imagePath*/
  });

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
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
      });

      connection?.input?.listen(null).onDone(() {
        setState(() {
          isConnected = false;
        });
      });
    } catch (e) {
      // Handle connection error
      setState(() {
        isConnected = false;
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
        title: const Text(
          'LED con Bluetooth',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AnimatedBuilder(
        animation: _controller,
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
                StarAnimation(animation: _controller),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      isLoading
                          ? const CircularProgressIndicator()
                          : DropdownButton<BluetoothDevice>(
                              value: selectedDevice,
                              hint: const Text("Selecciona un dispositivo",
                                  style: TextStyle(color: Colors.white)),
                              items: devicesList
                                  .map((device) => DropdownMenuItem(
                                        value: device,
                                        child: Text(
                                          device.name ?? "",
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 119, 119, 119)),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (device) {
                                setState(() {
                                  selectedDevice = device;
                                });
                                if (device != null) {
                                  _connectToBluetoothDevice(device);
                                }
                              },
                            ),
                      const SizedBox(height: 60),
                      const Text(
                        'Selecciona un color para el LED:',
                        style: TextStyle(color: Colors.white, fontSize: 20),
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
                      const SizedBox(height: 20),
                      Text(
                        isConnected ? "Conectado" : "Desconectado",
                        style: TextStyle(
                          color: isConnected ? Colors.green : Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
