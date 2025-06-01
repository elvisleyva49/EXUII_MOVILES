import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ERLS_seat_view.dart';

class UserPanel extends StatelessWidget {
  bool _isConciertoActive(String fecha, String hora) {
    try {
      DateTime now = DateTime.now();
      List<String> fechaParts = fecha.split('/');
      List<String> horaParts = hora.split(':');
      
      DateTime conciertoDateTime = DateTime(
        int.parse(fechaParts[2]), // año
        int.parse(fechaParts[1]), // mes
        int.parse(fechaParts[0]), // día
        int.parse(horaParts[0]),  // hora
        int.parse(horaParts[1]),  // minuto
      );

      return conciertoDateTime.isAfter(now);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Panel Cliente')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('conciertos')
            .orderBy('fechaCreacion', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var conciertosActivos = snapshot.data!.docs.where((concierto) {
            return _isConciertoActive(concierto['fecha'], concierto['hora']);
          }).toList();

          if (conciertosActivos.isEmpty) {
            return Center(child: Text('No hay conciertos disponibles'));
          }

          return ListView.builder(
            itemCount: conciertosActivos.length,
            itemBuilder: (context, index) {
              var concierto = conciertosActivos[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(concierto['nombre']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fecha: ${concierto['fecha']}'),
                      Text('Hora: ${concierto['hora']}'),
                      Text('Lugar: ${concierto['lugar']}'),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeatView(
                          conciertoId: concierto.id,
                          conciertoNombre: concierto['nombre'],
                          isAdmin: false,
                        ),
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