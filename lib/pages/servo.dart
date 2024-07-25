import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ServoControlScreen extends StatefulWidget {
  @override
  _ServoControlScreenState createState() => _ServoControlScreenState();
}

class _ServoControlScreenState extends State<ServoControlScreen> {
  double _currentAngle = 0;
  bool _isLoading = false;

  Future<void> _sendAngle(double angle) async {
    final String url = 'http://192.168.0.163/servo1?angle=${angle.toInt()}';
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Control exitoso del servomotor
        print("Servo moved to $angle degrees");
      } else {
        // Manejo de error
        print("Error moving servo: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Servo Motor Control'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Set Servo Angle',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              '${_currentAngle.toInt()}°',
              style: TextStyle(fontSize: 40, color: Colors.blue),
            ),
            Slider(
              value: _currentAngle,
              min: 0,
              max: 180,
              divisions: 180,
              label: _currentAngle.toInt().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentAngle = value;
                });
              },
              onChangeEnd: (double value) {
                _sendAngle(value);
              },
            ),
            if (_isLoading)
              CircularProgressIndicator()
            else
              SizedBox(height: 0),
          ],
        ),
      ),
    );
  }
}