import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../solicitudes/ERLS_detalle_solicitud.dart';
import '../../../services/auth_service.dart'; 

class HomeDecano extends StatelessWidget {
  final Map<String, dynamic> userData;
  
  HomeDecano({required this.userData});

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
      appBar: AppBar(
        title: Text('Decano'), // O el título correspondiente
        backgroundColor: Colors.blue, // O el color que uses
        foregroundColor: Colors.white,
        actions: [
          // Botón de cerrar sesión
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => AuthService.showLogoutDialog(context),
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('solicitud')
            .where('estado', isEqualTo: 'decano')
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
            return Center(child: Text('No hay solicitudes pendientes'));
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
                  subtitle: Text('${data['nombres']} ${data['apellidos']}\nCódigo: ${data['codigo']}'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleSolicitud(
                          solicitudId: doc.id,
                          solicitudData: data,
                          userRole: 'decano',
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