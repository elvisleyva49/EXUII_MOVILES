import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MisSolicitudes extends StatelessWidget {
  final Map<String, dynamic> userData;

  MisSolicitudes({required this.userData});

  Color _getColorByEstado(String estado) {
    switch (estado) {
      case 'secretaria':
        return Colors.yellow[700]!;
      case 'decano':
        return Colors.cyan;
      case 'aprobado':
        return Colors.green;
      case 'desaprobado':
        return Colors.red;
      case 'direccion':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis Solicitudes')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('solicitud')
            .where('usuario_id', isEqualTo: userData['id'])
            .orderBy('fecha_solicitud', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No tienes solicitudes'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(_getTipoString(data['tipo'] ?? 0)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estado: ${data['estado']}'),
                      if (data['observaciones'] != null)
                        Text('Observaciones: ${data['observaciones']}',
                             style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  trailing: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getColorByEstado(data['estado'] ?? ''),
                      shape: BoxShape.circle,
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(_getTipoString(data['tipo'] ?? 0)),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Estado: ${data['estado']}'),
                              SizedBox(height: 10),
                              if (data['observaciones'] != null) ...[
                                Text('Observaciones:',
                                     style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('${data['observaciones']}',
                                     style: TextStyle(color: Colors.red)),
                                SizedBox(height: 10),
                              ],
                              Text('Fecha: ${data['hora_solicitud'] ?? 'N/A'}'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}