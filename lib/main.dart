// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'ERLS_login_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Venta Asientos Conciertos',
//       home: LoginScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login.dart';
// Importa tus pantallas de home (ajusta las rutas según tu estructura)
import 'home_usuario.dart';
import 'home_secretaria.dart';
import 'home_decano.dart';

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
      // Pantalla inicial
      home: LoginScreen(),
      // Rutas nombradas para la navegación
      routes: {
        '/login': (context) => LoginScreen(),
        '/home_usuario': (context) => HomeUsuario(userData: {}), // Ajusta según tus parámetros
        '/home_secretaria': (context) => HomeSecretaria(userData: {}), // Ajusta según tus parámetros
        '/home_decano': (context) => HomeDecano(userData: {}), // Ajusta según tus parámetros
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