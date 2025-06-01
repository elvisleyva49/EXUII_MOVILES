import 'package:flutter/material.dart';
import 'ERLS_login.dart';
// Importa tus pantallas de home (ajusta las rutas según tu estructura)
import 'ERLS_home_usuario.dart';
import 'ERLS_home_secretaria.dart';
import 'ERLS_home_decano.dart';
import 'ERLS_home_direccion.dart';

class Caso1App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Solicitudes',
      debugShowCheckedModeBanner: false,
      // Pantalla inicial
      home: LoginScreen(),
      // Rutas nombradas para la navegación
      routes: {
        '/login': (context) => LoginScreen(),
        '/home_usuario': (context) => HomeUsuario(userData: {}),
        '/home_secretaria': (context) => HomeSecretaria(userData: {}),
        '/home_decano': (context) => HomeDecano(userData: {}),
        '/home_direccion': (context) => HomeDireccion(userData: {}),
      },
      // Ruta inicial nombrada
      initialRoute: '/',
      // Manejo de rutas no definidas
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => LoginScreen(),
        );
      },
    );
  }
}