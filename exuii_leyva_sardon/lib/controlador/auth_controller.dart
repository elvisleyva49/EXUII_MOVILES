import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelo/usuario.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signUp(Usuario usuario, String password) async {
    try {
      // Paso 1: Crear en Authentication
      await _auth.createUserWithEmailAndPassword(
        email: usuario.correo,
        password: password,
      );
      
      // Paso 2: Obtener el UID del usuario actual
      String? uid = _auth.currentUser?.uid;
      
      if (uid != null) {
        // Paso 3: Crear documento en Firestore con ese UID
        await _firestore.collection('users').doc(uid).set(usuario.toMap());
      }
      
      return true;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}