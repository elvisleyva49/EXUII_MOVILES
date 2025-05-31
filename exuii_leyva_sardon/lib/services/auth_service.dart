// auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Verificar credenciales directamente en Firestore
  Future<DocumentSnapshot?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final query = await _firestore
          .collection('usuarios')
          .where('correo', isEqualTo: email)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();
      
      return query.docs.isNotEmpty ? query.docs.first : null;
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  // Registrar usuario directamente en Firestore
  Future<DocumentReference> registerUser(Map<String, dynamic> userData) async {
    return await _firestore.collection('usuarios').add(userData);
  }

  // Cerrar sesión (en este caso solo limpiar el estado local)
  Future<void> signOut() async {
    // No hay operación real ya que no usamos Firebase Auth
    await Future.delayed(Duration.zero);
  }
}