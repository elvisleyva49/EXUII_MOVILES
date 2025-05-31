import '../models/seat_model.dart';
import '../services/firestore_service.dart';

class SeatController {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<List<SeatModel>> getSeats() {
    return _firestoreService.getSeatsStream().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SeatModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> occupySeats(List<String> seatIds) async {
    await _firestoreService.updateSeats(seatIds);
  }
}