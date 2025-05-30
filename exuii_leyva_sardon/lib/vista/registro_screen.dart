import 'package:flutter/material.dart';
import '../controlador/auth_controller.dart';
import '../modelo/usuario.dart';

class RegistroScreen extends StatefulWidget {
  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = AuthController();
  String _rolSeleccionado = 'usuario';

  void _registrar() async {
    Usuario usuario = Usuario(
      nombres: _nombresController.text,
      apellidos: _apellidosController.text,
      correo: _correoController.text,
      telefono: _telefonoController.text,
      rol: _rolSeleccionado,
    );

    bool result = await _authController.signUp(usuario, _passwordController.text);
    
    if (result) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombresController,
              decoration: InputDecoration(labelText: 'Nombres'),
            ),
            TextField(
              controller: _apellidosController,
              decoration: InputDecoration(labelText: 'Apellidos'),
            ),
            TextField(
              controller: _correoController,
              decoration: InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: _telefonoController,
              decoration: InputDecoration(labelText: 'Teléfono'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            DropdownButton<String>(
              value: _rolSeleccionado,
              items: [
                DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
              ],
              onChanged: (value) => setState(() => _rolSeleccionado = value!),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registrar,
              child: Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}