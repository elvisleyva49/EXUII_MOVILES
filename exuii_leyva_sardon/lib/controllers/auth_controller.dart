import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthController {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final userDoc = await _authService.signInWithEmailAndPassword(email, password);
      if (userDoc != null) {
        _currentUser = UserModel.fromMap(
          userDoc.data() as Map<String, dynamic>,
          userDoc.id,
        );
        return _currentUser;
      }
      return null;
    } catch (e) {
      debugPrint('Error en controlador de login: $e');
      return null;
    }
  }

  Future<UserModel?> register(
    String nombres,
    String apellidos,
    String email,
    String dni,
    String password,
  ) async {
    try {
      final userModel = UserModel(
        nombres: nombres,
        apellidos: apellidos,
        correo: email,
        dni: dni,
        password: password,
        tipo: 'usuario',
        fechaRegistro: DateTime.now(),
      );
      
      final docRef = await _authService.registerUser(userModel.toMap());
      _currentUser = userModel.copyWith(id: docRef.id);
      return _currentUser;
    } catch (e) {
      debugPrint('Error en controlador de registro: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
  }
}