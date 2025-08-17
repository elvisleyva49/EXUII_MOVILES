import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/ERLS_home_usuario.dart';
import '../home/ERLS_home_secretaria.dart';
import '../home/ERLS_home_decano.dart';
import '../home/ERLS_home_direccion.dart';
import 'ERLS_registro_estudiante.dart'; // Nueva importación

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
        } else if (rol == 'direccion') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeDireccion(userData: userData),
            ),
          );
        }
      } else {
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
      appBar: AppBar(
        title: Text('Iniciar Sesión'),
        backgroundColor: Color(0xFF1d1c3f),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Center( // Opcional para centrar en pantallas grandes
          child: ConstrainedBox( // Opcional para limitar ancho en pantallas grandes
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
                
                // Título
                Text(
                  'Sistema de Solicitudes UPT',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1d1c3f),
                  ),
                ),
                SizedBox(height: 40),
                
                // Campos de login
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1d1c3f)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1d1c3f), width: 2),
                    ),
                    prefixIcon: Icon(Icons.email, color: Color(0xFF1d1c3f)),
                    labelStyle: TextStyle(color: Color(0xFF1d1c3f)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1d1c3f)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF1d1c3f), width: 2),
                    ),
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF1d1c3f)),
                    labelStyle: TextStyle(color: Color(0xFF1d1c3f)),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 24),
                
                // Botón de login
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1d1c3f),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Ingresar',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Divisor
                Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFF1d1c3f))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'o',
                        style: TextStyle(color: Color(0xFF1d1c3f)),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFF1d1c3f))),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Botón de registro
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistroEstudianteScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF1d1c3f)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Registrar Estudiante',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1d1c3f),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}