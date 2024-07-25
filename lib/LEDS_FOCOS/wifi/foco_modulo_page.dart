// Importando los paquetes necesarios
// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:face_net_authentication/LEDS_FOCOS/bluetooth/bluetooth_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// Creando el StatefulWidget para manejar el estado del foco RGB
class RgbBulbScreen extends StatefulWidget {
  const RgbBulbScreen({super.key});

  @override
  _RgbBulbScreenState createState() => _RgbBulbScreenState();
}

// Creando el State asociado al StatefulWidget
class _RgbBulbScreenState extends State<RgbBulbScreen> {
  // Definiendo la URL del ESP8266
  final String _esp8266Url = 'http://192.168.0.163';
  // Inicializando el color del foco RGB como blanco
  Color _currentColor = Colors.white;

  // Función para enviar el color seleccionado al ESP8266
  Future<void> _sendColorToEsp8266(Color color) async {
    await http.get(Uri.parse(
        '$_esp8266Url/color?r=${color.red}&g=${color.green}&b=${color.blue}'));
  }

  // Construyendo la interfaz de usuario
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 3, 76, 136),
        foregroundColor: Colors.white,
        title: Text('Dashboard'),
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
                    builder: (context) => const BluetoothLedControlScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Bluetooth'),
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Control Foco RGB'),
    //     backgroundColor: Colors.black,
    //     iconTheme: const IconThemeData(color: Colors.white),
    //   ),
    //   body: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         // Mostrando el texto descriptivo
    //         const Text('Selecciona un color para el foco RGB:'),
    //         const SizedBox(height: 20),
    //         // Creando el selector de color
    //         BlockPicker(
    //           pickerColor: _currentColor,
    //           onColorChanged: (Color color) {
    //             // Actualizando el color seleccionado
    //             setState(() {
    //               _currentColor = color;
    //             });
    //           },
    //         ),
    //         const SizedBox(height: 20),
    //         // Creando el botón para enviar el color seleccionado al ESP8266
    //         ElevatedButton(
    //           onPressed: () => _sendColorToEsp8266(_currentColor),
    //           child: const Text('Cambiar color'),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
