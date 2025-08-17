import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroEstudianteScreen extends StatefulWidget {
  @override
  _RegistroEstudianteScreenState createState() => _RegistroEstudianteScreenState();
}

class _RegistroEstudianteScreenState extends State<RegistroEstudianteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  String _selectedEscuela = 'EPIS';
  String _selectedFacultad = 'FAING';
  bool _isLoading = false;

  final List<String> _escuelas = [
    'EPIS', 'EPIC', 'EPIE', 'EPIA', 'EPIM', 'EPIQ', 'EPAM', 'EPCO', 'EPDE', 'EPAR'
  ];

  final List<String> _facultades = [
    'FAING', 'FACSA', 'FAEDU', 'FACDE'
  ];

  Future<bool> _verificarEmailExistente(String email) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usuario_data')
          .where('email', isEqualTo: email.trim())
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _verificarCodigoExistente(String codigo) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usuario_data')
          .where('codigo', isEqualTo: codigo.trim())
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _verificarDniExistente(String dni) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usuario_data')
          .where('dni', isEqualTo: dni.trim())
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _registrarEstudiante() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Verificar duplicados
      bool emailExiste = await _verificarEmailExistente(_emailController.text);
      if (emailExiste) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El email ya está registrado'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      bool codigoExiste = await _verificarCodigoExistente(_codigoController.text);
      if (codigoExiste) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El código de estudiante ya está registrado'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      bool dniExiste = await _verificarDniExistente(_dniController.text);
      if (dniExiste) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El DNI ya está registrado'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Crear el documento del estudiante
      Map<String, dynamic> estudianteData = {
        'nombres': _nombresController.text.trim(),
        'apellidos': _apellidosController.text.trim(),
        'dni': _dniController.text.trim(),
        'codigo': _codigoController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'password': _passwordController.text.trim(),
        'escuela': _selectedEscuela,
        'facultad': _selectedFacultad,
        'rol': 'usuario',
        'fecha_registro': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('usuario_data')
          .add(estudianteData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estudiante registrado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Regresar al login
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  String? _validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es obligatorio';
    }
    if (!value.contains('@')) {
      return 'Ingrese un email válido';
    }
    if (!value.endsWith('@upt.pe')) {
      return 'El email debe terminar en @upt.pe';
    }
    return null;
  }

  String? _validarDNI(String? value) {
    if (value == null || value.isEmpty) {
      return 'El DNI es obligatorio';
    }
    if (value.length != 8) {
      return 'El DNI debe tener 8 dígitos';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'El DNI solo debe contener números';
    }
    return null;
  }

  String? _validarCodigo(String? value) {
    if (value == null || value.isEmpty) {
      return 'El código es obligatorio';
    }
    if (value.length != 10) {
      return 'El código debe tener 10 dígitos';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'El código solo debe contener números';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = Color(0xFF1d1c3f);

    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Estudiante'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
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

                // Nombres
                TextFormField(
                  controller: _nombresController,
                  decoration: InputDecoration(
                    labelText: 'Nombres',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor, width: 2),
                    ),
                    prefixIcon: Icon(Icons.person, color: mainColor),
                    labelStyle: TextStyle(color: mainColor),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Los nombres son obligatorios';
                    }
                    if (value.trim().length < 2) {
                      return 'Los nombres deben tener al menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Apellidos
                TextFormField(
                  controller: _apellidosController,
                  decoration: InputDecoration(
                    labelText: 'Apellidos',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor, width: 2),
                    ),
                    prefixIcon: Icon(Icons.person_outline, color: mainColor),
                    labelStyle: TextStyle(color: mainColor),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Los apellidos son obligatorios';
                    }
                    if (value.trim().length < 2) {
                      return 'Los apellidos deben tener al menos 2 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // DNI
                TextFormField(
                  controller: _dniController,
                  decoration: InputDecoration(
                    labelText: 'DNI',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor, width: 2),
                    ),
                    prefixIcon: Icon(Icons.badge, color: mainColor),
                    labelStyle: TextStyle(color: mainColor),
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validarDNI,
                ),
                SizedBox(height: 16),

                // Código
                TextFormField(
                  controller: _codigoController,
                  decoration: InputDecoration(
                    labelText: 'Código de Estudiante',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor, width: 2),
                    ),
                    prefixIcon: Icon(Icons.numbers, color: mainColor),
                    labelStyle: TextStyle(color: mainColor),
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validarCodigo,
                ),
                SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email (debe terminar en @upt.pe)',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor, width: 2),
                    ),
                    prefixIcon: Icon(Icons.email, color: mainColor),
                    labelStyle: TextStyle(color: mainColor),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validarEmail,
                ),
                SizedBox(height: 16),

                // Facultad
                DropdownButtonFormField<String>(
                  value: _selectedFacultad,
                  decoration: InputDecoration(
                    labelText: 'Facultad',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor),
                    ),
                    prefixIcon: Icon(Icons.school, color: mainColor),
                    labelStyle: TextStyle(color: mainColor),
                  ),
                  items: _facultades.map((String facultad) {
                    return DropdownMenuItem<String>(
                      value: facultad,
                      child: Text(facultad),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFacultad = newValue!;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Escuela
                DropdownButtonFormField<String>(
                  value: _selectedEscuela,
                  decoration: InputDecoration(
                    labelText: 'Escuela Profesional',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor),
                    ),
                    prefixIcon: Icon(Icons.business, color: mainColor),
                    labelStyle: TextStyle(color: mainColor),
                  ),
                  items: _escuelas.map((String escuela) {
                    return DropdownMenuItem<String>(
                      value: escuela,
                      child: Text(escuela),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedEscuela = newValue!;
                    });
                  },
                ),
                SizedBox(height: 16),

                // Contraseña
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor, width: 2),
                    ),
                    prefixIcon: Icon(Icons.lock, color: mainColor),
                    labelStyle: TextStyle(color: mainColor),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La contraseña es obligatoria';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Confirmar contraseña
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor, width: 2),
                    ),
                    prefixIcon: Icon(Icons.lock_outline, color: mainColor),
                    labelStyle: TextStyle(color: mainColor),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Debe confirmar la contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                // Botón registrar
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registrarEstudiante,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Registrar Estudiante',
                            style: TextStyle(fontSize: 16),
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