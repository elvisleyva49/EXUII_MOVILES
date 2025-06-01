import 'package:flutter/material.dart';
import 'ERLS_login_screen.dart';

class Caso2App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Venta Asientos Conciertos',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}