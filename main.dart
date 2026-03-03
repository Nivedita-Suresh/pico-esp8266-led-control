import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool ledOn = false;
  bool connected = false;
  bool _isSending = false;

  final String baseUrl = "http://192.168.4.1";

  Future<bool> sendCommand(String command) async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl/$command"))
          .timeout(const Duration(seconds: 2));

      // Only update state if we got HTTP 200
      if (response.statusCode == 200) {
        setState(() {
          connected = true;
          ledOn = command == "on";
        });
        return true;
      } else {
        setState(() {
          connected = false;
        });
        return false;
      }
    } catch (e) {
      setState(() {
        connected = false;
        ledOn = false;
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("LED Control"),
          backgroundColor: connected ? Colors.green : Colors.red,
        ),
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SwitchListTile(
                title: Text(
                  ledOn ? "LED ON" : "LED OFF",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                value: ledOn,
                onChanged: _isSending
                    ? null
                    : (bool value) {
                        // Optimistic UI update
                        setState(() {
                          ledOn = value;
                          _isSending = true;
                        });

                        // Send command and revert if it fails
                        sendCommand(value ? "on" : "off").then((success) {
                          if (mounted) {
                            setState(() {
                              _isSending = false;
                              if (!success) {
                                ledOn = !value; // revert on failure
                              }
                            });
                          }
                        });
                      },
              ),
              if (_isSending)
                const Positioned(
                  right: 24,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
