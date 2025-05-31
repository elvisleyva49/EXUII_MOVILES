// services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para crear 70 asientos iniciales
  Future<void> createInitialSeats() async {
    // Verificar si ya existen asientos
    final seatsSnapshot = await _firestore.collection('asientos').limit(1).get();
    if (seatsSnapshot.docs.isNotEmpty) return; // Ya existen asientos
    
    final batch = _firestore.batch();
    
    // Crear 70 asientos (A1-A10, B1-B10, ..., G1-G10)
    for (int row = 0; row < 7; row++) {
      final rowLetter = String.fromCharCode(65 + row); // A, B, C, ..., G
      
      for (int number = 1; number <= 10; number++) {
        final seatId = '$rowLetter$number'; // A1, A2, ..., G10
        final docRef = _firestore.collection('asientos').doc(seatId);
        
        batch.set(docRef, {
          'numero': seatId,
          'estado': 'disponible',
          'fechaCreacion': FieldValue.serverTimestamp(),
        });
      }
    }
    
    await batch.commit();
  }

  // Resto de tus métodos existentes...
  Stream<QuerySnapshot> getSeatsStream() {
    return _firestore.collection('asientos').orderBy('numero').snapshots();
  }

  Future<void> updateSeats(List<String> seatIds) async {
    final batch = _firestore.batch();
    for (var seatId in seatIds) {
      final seatRef = _firestore.collection('asientos').doc(seatId);
      batch.update(seatRef, {'estado': 'ocupado'});
    }
    await batch.commit();
  }
}