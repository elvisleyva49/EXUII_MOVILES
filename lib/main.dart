import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'ERLS_login.dart'; // Asegúrate de importar tu pantalla de login

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Solicitudes',
      debugShowCheckedModeBanner: false,
      // Define las rutas
      routes: {
        '/': (context) => LoginScreen(), // Pantalla inicial es login
        '/login': (context) => LoginScreen(),
      },
      initialRoute: '/',
    );
  }
}