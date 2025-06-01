import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_usuario.dart';
import 'home_secretaria.dart';
import 'home_decano.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usuario_data')
          .where('email', isEqualTo: _emailController.text.trim())
          .where('password', isEqualTo: _passwordController.text.trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        userData['id'] = userDoc.id;

        String rol = userData['rol'] ?? '';

        if (rol == 'usuario') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeUsuario(userData: userData),
            ),
          );
        } else if (rol == 'secretaria') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeSecretaria(userData: userData),
            ),
          );
        } else if (rol == 'decano') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeDecano(userData: userData),
            ),
          );
        }
      } 
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario o contraseña incorrectos')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar Sesión')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: Text('Ingresar'),
                  ),
          ],
        ),
      ),
    );
  }
}