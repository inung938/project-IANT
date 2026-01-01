import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const IANTApp());
}

// void main() {
//   runApp(const TestConnectionApp());
// }

class IANTApp extends StatelessWidget {
  const IANTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IANT App',
      theme: ThemeData.dark(),
      home: const OnboardingScreen(),
    );
  }
}

class TestConnectionApp extends StatelessWidget {
  const TestConnectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IANT Backend Test',
      theme: ThemeData.dark(),
      home: const ConnectionTestScreen(),
    );
  }
}

class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({super.key});

  @override
  State<ConnectionTestScreen> createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  String result = "Menunggu hasil koneksi...";

  void checkConnection() async {
    setState(() => result = "Menghubungkan...");
    final message = await ApiService.testConnection();
    setState(() => result = message);
  }

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tes Koneksi Backend")),
      body: Center(
        child: Text(
          result,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}