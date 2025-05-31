import 'package:cloud_firestore/cloud_firestore.dart';

// models/user_model.dart
class UserModel {
  final String? id;
  final String nombres;
  final String apellidos;
  final String correo;
  final String dni;
  final String password;
  final String tipo;
  final DateTime fechaRegistro;

  UserModel({
    this.id,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.dni,
    required this.password,
    required this.tipo,
    required this.fechaRegistro,
  });

  // Método para copiar el modelo con nuevos valores
  UserModel copyWith({
    String? id,
    String? nombres,
    String? apellidos,
    String? correo,
    String? dni,
    String? password,
    String? tipo,
    DateTime? fechaRegistro,
  }) {
    return UserModel(
      id: id ?? this.id,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      correo: correo ?? this.correo,
      dni: dni ?? this.dni,
      password: password ?? this.password,
      tipo: tipo ?? this.tipo,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      nombres: data['nombres'] ?? '',
      apellidos: data['apellidos'] ?? '',
      correo: data['correo'] ?? '',
      dni: data['dni'] ?? '',
      password: data['password'] ?? '',
      tipo: data['tipo'] ?? 'usuario',
      fechaRegistro: (data['fechaRegistro'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombres': nombres,
      'apellidos': apellidos,
      'correo': correo,
      'dni': dni,
      'password': password,
      'tipo': tipo,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
    };
  }
}