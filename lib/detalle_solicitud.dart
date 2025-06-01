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

  String _getEstadoString(String estado) {
    switch (estado) {
      case 'secretaria':
        return 'Pendiente - Secretaría';
      case 'decano':
        return 'Pendiente - Decanato';
      case 'secretaria_pendiente':
        return 'Aprobado por Decanato';
      case 'aprobado':
        return 'Aprobado';
      case 'rechazado':
        return 'Rechazado';
      default:
        return estado;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'secretaria':
      case 'decano':
      case 'secretaria_pendiente':
        return Colors.orange;
      case 'aprobado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _aprobarSolicitud() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String nuevoEstado;
      Map<String, dynamic> updateData = {};

      if (widget.userRole == 'decano') {
        // Decano aprueba -> pasa a secretaria_pendiente
        nuevoEstado = 'secretaria_pendiente';
        updateData = {
          'estado': nuevoEstado,
          'fecha_aprobacion_decano': FieldValue.serverTimestamp(),
        };
      } else if (widget.userRole == 'secretaria_final') {
        // Secretaria aprobación final -> aprobado
        nuevoEstado = 'aprobado';
        updateData = {
          'estado': nuevoEstado,
          'fecha_aprobacion': FieldValue.serverTimestamp(),
        };
      } else {
        // Secretaria normal -> decano
        nuevoEstado = 'decano';
        updateData = {
          'estado': nuevoEstado,
          'fecha_revision_secretaria': FieldValue.serverTimestamp(),
        };
      }

      await FirebaseFirestore.instance
          .collection('solicitud')
          .doc(widget.solicitudId)
          .update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Solicitud aprobada correctamente'),
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
    // Mostrar diálogo para motivo de rechazo
    String? motivo = await _showMotivoDialog();
    if (motivo == null || motivo.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('solicitud')
          .doc(widget.solicitudId)
          .update({
        'estado': 'rechazado',
        'motivo_rechazo': motivo,
        'fecha_rechazo': FieldValue.serverTimestamp(),
        'rechazado_por': widget.userRole,
      });

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

  Future<String?> _showMotivoDialog() async {
    String motivo = '';
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Motivo de rechazo'),
          content: TextField(
            onChanged: (value) => motivo = value,
            decoration: InputDecoration(
              hintText: 'Ingrese el motivo del rechazo...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Rechazar', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(motivo),
            ),
          ],
        );
      },
    );
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.white),
            title: Text('Voucher de Pago', style: TextStyle(color: Colors.white)),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / 
                            loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.white, size: 64),
                      SizedBox(height: 16),
                      Text(
                        'No se pudo cargar la imagen',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Solicitud'),
        backgroundColor: _getEstadoColor(widget.solicitudData['estado']),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado actual
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getEstadoColor(widget.solicitudData['estado']).withOpacity(0.1),
                border: Border.all(color: _getEstadoColor(widget.solicitudData['estado'])),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info,
                    color: _getEstadoColor(widget.solicitudData['estado']),
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    _getEstadoString(widget.solicitudData['estado']),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getEstadoColor(widget.solicitudData['estado']),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Información del estudiante
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Estudiante',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildInfoRow('Nombres:', widget.solicitudData['nombres']),
                    _buildInfoRow('Apellidos:', widget.solicitudData['apellidos']),
                    _buildInfoRow('DNI:', widget.solicitudData['dni']),
                    _buildInfoRow('Código:', widget.solicitudData['codigo']),
                    _buildInfoRow('Escuela:', widget.solicitudData['escuela']),
                    _buildInfoRow('Facultad:', widget.solicitudData['facultad']),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Tipo de solicitud
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo de Solicitud',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _getTipoString(widget.solicitudData['tipo'] ?? 0),
                      style: TextStyle(fontSize: 16),
                    ),
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
                      'Contenido de la Solicitud',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.solicitudData['texto_solicitud'] ?? 'No disponible',
                        style: TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Voucher - Ahora muestra la imagen directamente
            if (widget.solicitudData['voucher'] != null)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voucher de Pago',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => _showFullScreenImage(widget.solicitudData['voucher']),
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.solicitudData['voucher'],
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / 
                                          loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[100],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error, color: Colors.grey, size: 48),
                                      SizedBox(height: 8),
                                      Text(
                                        'No se pudo cargar la imagen',
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Toca la imagen para verla en tamaño completo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 20),

            // Botones de acción
            if (!_isLoading) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _aprobarSolicitud,
                      child: Text('Aprobar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _rechazarSolicitud,
                      child: Text('Rechazar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 12),
                    Text('Procesando...'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'No disponible',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}