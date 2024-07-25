import 'package:face_net_authentication/LEDS_FOCOS/bluetooth/bluetooth_page.dart';
import 'package:face_net_authentication/pages/servo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SensorDataScreen extends StatefulWidget {
  @override
  _SensorDataScreenState createState() => _SensorDataScreenState();
}

class _SensorDataScreenState extends State<SensorDataScreen> {
  String temperature = "Loading...";
  String humidity = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchSensorData();
  }

  Future<void> fetchSensorData() async {
    final String url = 'http://192.168.0.163/dht';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = response.body;
        setState(() {
          temperature = _extractValue(data, 'Temperatura');
          humidity = _extractValue(data, 'Humedad');
        });
      } else {
        setState(() {
          temperature = "Error";
          humidity = "Error";
        });
      }
    } catch (e) {
      setState(() {
        temperature = "Error";
        humidity = "Error";
      });
    }
  }

  String _extractValue(String data, String key) {
    final RegExp regExp = RegExp('$key: ([0-9.]+)');
    final match = regExp.firstMatch(data);
    return match != null
        ? '${match.group(1)} ${key == "Temperatura" ? "°C" : "%"}'
        : "N/A";
  }

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SensorCard(
              label: 'Temperature',
              value: temperature,
              icon: Icons.thermostat,
              color: Colors.orange,
            ),
            SizedBox(height: 20),
            SensorCard(
              label: 'Humidity',
              value: humidity,
              icon: Icons.water_drop,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

class SensorCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const SensorCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 50, color: color),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
