class Usuario {
  String? id;
  String nombres;
  String apellidos;
  String correo;
  String telefono;
  String rol;

  Usuario({
    this.id,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.telefono,
    this.rol = 'usuario',
  });

  Map<String, dynamic> toMap() {
    return {
      'nombres': nombres,
      'apellidos': apellidos,
      'correo': correo,
      'telefono': telefono,
      'rol': rol,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombres: map['nombres'] ?? '',
      apellidos: map['apellidos'] ?? '',
      correo: map['correo'] ?? '',
      telefono: map['telefono'] ?? '',
      rol: map['rol'] ?? 'usuario',
    );
  }
}