// models/seat_model.dart
class SeatModel {
  final String id;
  final String numero;
  final String estado; // 'disponible', 'ocupado', 'reservado'
  final DateTime? fechaCreacion;

  SeatModel({
    required this.id,
    required this.numero,
    required this.estado,
    this.fechaCreacion,
  });

  factory SeatModel.fromMap(Map<String, dynamic> data, String id) {
    return SeatModel(
      id: id,
      numero: data['numero'] ?? '',
      estado: data['estado'] ?? 'disponible',
      fechaCreacion: data['fechaCreacion']?.toDate(),
    );
  }
}