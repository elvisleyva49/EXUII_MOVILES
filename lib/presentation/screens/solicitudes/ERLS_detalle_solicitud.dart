import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetalleSolicitud extends StatefulWidget {
  final String solicitudId;
  final Map<String, dynamic> solicitudData;
  final String userRole;

  DetalleSolicitud({
    required this.solicitudId,
    required this.solicitudData,
    required this.userRole,
  });

  @override
  _DetalleSolicitudState createState() => _DetalleSolicitudState();
}

class _DetalleSolicitudState extends State<DetalleSolicitud> {
  final TextEditingController _observacionesController = TextEditingController();
  bool _isLoading = false;

  String _getTipoString(int tipo) {
    switch (tipo) {
      case 1:
        return 'Separación de ciclo';
      case 2:
        return 'Constancia de estudios';
      case 3:
        return 'Prácticas profesionales';
      default:
        return 'Desconocido';
    }
  }

  String _getEstadoSiguiente() {
    String estadoActual = widget.solicitudData['estado'] ?? '';
    int tipoSolicitud = widget.solicitudData['tipo'] ?? 0;

    // Para prácticas profesionales (tipo 3) - flujo especial
    if (tipoSolicitud == 3) {
      switch (estadoActual) {
        case 'secretaria':
          return 'decano';
        case 'decano':
          return 'direccion'; // NUEVO: va a dirección
        case 'direccion':
          return 'secretaria_pendiente'; // NUEVO: dirección aprueba y va a secretaría final
        case 'secretaria_pendiente':
          return 'aprobado';
        default:
          return 'aprobado';
      }
    } else {
      // Para separación de ciclo y constancia de estudios - flujo normal
      switch (estadoActual) {
        case 'secretaria':
          return 'decano';
        case 'decano':
          return 'secretaria_pendiente';
        case 'secretaria_pendiente':
          return 'aprobado';
        default:
          return 'aprobado';
      }
    }
  }

  // LA LÓGICA CRÍTICA DE APROBACIÓN
  Future<void> _aprobarSolicitud() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String nuevoEstado = _getEstadoSiguiente();
      Map<String, dynamic> updateData = {
        'estado': nuevoEstado,
      };

      // Si es el estado final (aprobado), agregar fecha de aprobación
      if (nuevoEstado == 'aprobado') {
        updateData['fecha_aprobacion'] = FieldValue.serverTimestamp();
      }

      // Agregar información del aprobador según el rol
      switch (widget.userRole) {
        case 'secretaria':
          updateData['aprobado_por_secretaria'] = DateTime.now().toIso8601String();
          break;
        case 'decano':
          updateData['aprobado_por_decano'] = DateTime.now().toIso8601String();
          break;
        case 'direccion': // NUEVO CASO
          updateData['aprobado_por_direccion'] = DateTime.now().toIso8601String();
          break;
        case 'secretaria_final':
          updateData['aprobado_por_secretaria_final'] = DateTime.now().toIso8601String();
          break;
      }

      await FirebaseFirestore.instance
          .collection('solicitud')
          .doc(widget.solicitudId)
          .update(updateData);

      if (mounted) {
        String mensaje = '';
        if (nuevoEstado == 'aprobado') {
          mensaje = 'Solicitud aprobada exitosamente';
        } else {
          switch (nuevoEstado) {
            case 'decano':
              mensaje = 'Solicitud enviada al Decanato';
              break;
            case 'direccion':
              mensaje = 'Solicitud enviada a Dirección Académica';
              break;
            case 'secretaria_pendiente':
              mensaje = 'Solicitud enviada a Secretaría para finalización';
              break;
            default:
              mensaje = 'Solicitud procesada correctamente';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al aprobar solicitud: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _rechazarSolicitud() async {
    if (_observacionesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debe ingresar observaciones para rechazar la solicitud'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> updateData = {
        'estado': 'desaprobado',
        'observaciones': _observacionesController.text.trim(),
        'fecha_desaprobacion': FieldValue.serverTimestamp(),
      };

      // Agregar información del rechazador según el rol
      switch (widget.userRole) {
        case 'secretaria':
          updateData['rechazado_por_secretaria'] = DateTime.now().toIso8601String();
          break;
        case 'decano':
          updateData['rechazado_por_decano'] = DateTime.now().toIso8601String();
          break;
        case 'direccion': // NUEVO CASO
          updateData['rechazado_por_direccion'] = DateTime.now().toIso8601String();
          break;
        case 'secretaria_final':
          updateData['rechazado_por_secretaria_final'] = DateTime.now().toIso8601String();
          break;
      }

      await FirebaseFirestore.instance
          .collection('solicitud')
          .doc(widget.solicitudId)
          .update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Solicitud rechazada'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al rechazar solicitud: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getRoleName() {
    switch (widget.userRole) {
      case 'secretaria':
        return 'Secretaría';
      case 'decano':
        return 'Decanato';
      case 'direccion':
        return 'Dirección Académica';
      case 'secretaria_final':
        return 'Secretaría (Final)';
      default:
        return 'Usuario';
    }
  }

  Color _getRoleColor() {
    switch (widget.userRole) {
      case 'secretaria':
        return Colors.blue;
      case 'decano':
        return Colors.green;
      case 'direccion':
        return Colors.purple;
      case 'secretaria_final':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Solicitud'),
        backgroundColor: _getRoleColor(),
        foregroundColor: Colors.white,
      ),
      body: SafeArea( // <--- SOLO ENVUELVE EL BODY EN SafeArea
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con información básica
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getTipoString(widget.solicitudData['tipo'] ?? 0),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getRoleColor(),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getRoleName(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text('Estudiante: ${widget.solicitudData['nombres']} ${widget.solicitudData['apellidos']}'),
                      Text('Código: ${widget.solicitudData['codigo']}'),
                      Text('DNI: ${widget.solicitudData['dni']}'),
                      Text('Escuela: ${widget.solicitudData['escuela']}'),
                      Text('Estado actual: ${widget.solicitudData['estado']}'),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Contenido de la solicitud
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contenido de la solicitud:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.solicitudData['texto_solicitud'] ?? 'Sin contenido',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Campo de observaciones
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Observaciones (opcional para aprobar, obligatorio para rechazar):',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _observacionesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Ingrese observaciones...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _rechazarSolicitud,
                      icon: _isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.close),
                      label: Text('Rechazar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _aprobarSolicitud,
                      icon: _isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.check),
                      label: Text('Aprobar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}