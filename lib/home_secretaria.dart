import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detalle_solicitud.dart';
import 'auth_service.dart'; 

class HomeSecretaria extends StatelessWidget {
  final Map<String, dynamic> userData;
  
  HomeSecretaria({required this.userData});

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Panel Secretaría'),
          actions: [
            // Botón de cerrar sesión
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => AuthService.showLogoutDialog(context),
              tooltip: 'Cerrar Sesión',
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Solicitudes Pendientes'),
              Tab(text: 'Aprobadas por Decanato'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Primera pestaña: Solicitudes pendientes (estado 'secretaria')
            _buildSolicitudesPendientes(),
            // Segunda pestaña: Solicitudes aprobadas por decanato (estado 'secretaria_pendiente')
            _buildSolicitudesAprobadasDecanato(),
          ],
        ),
      ),
    );
  }

  Widget _buildSolicitudesPendientes() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('solicitud')
          .where('estado', isEqualTo: 'secretaria')
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
                        userRole: 'secretaria',
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSolicitudesAprobadasDecanato() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('solicitud')
          .where('estado', isEqualTo: 'secretaria_pendiente')
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.approval, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No hay solicitudes aprobadas por Decanato'),
              ],
            ),
          );
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
                    Text('${data['nombres']} ${data['apellidos']}'),
                    Text('Código: ${data['codigo']}'),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Aprobado por Decanato',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleSolicitud(
                        solicitudId: doc.id,
                        solicitudData: data,
                        userRole: 'secretaria_final',
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}