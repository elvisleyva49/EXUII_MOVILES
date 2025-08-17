import 'package:flutter/material.dart';
import '../solicitudes/ERLS_solicitud_generica.dart'; // Cambiamos esta importación
import '../solicitudes/ERLS_mis_solicitudes.dart';
import '../solicitudes/ERLS_solicitudes_aprobadas.dart';
import '../../../services/auth_service.dart';

class HomeUsuario extends StatelessWidget {
  final Map<String, dynamic> userData;
  
  HomeUsuario({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel Usuario'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => AuthService.showLogoutDialog(context),
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Bienvenido ${userData['nombres']} ${userData['apellidos']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            
            // Solicitar separación de ciclo
            ListTile(
              title: Text('Solicitar separación de ciclo'),
              leading: Icon(Icons.description),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SolicitudGenerica(
                      userData: userData,
                      tipoSolicitud: 1, // 1 = separación de ciclo
                    ),
                  ),
                );
              },
            ),
            
            // Solicitar constancia de estudios
            ListTile(
              title: Text('Solicitar constancia de estudios'),
              leading: Icon(Icons.school),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SolicitudGenerica(
                      userData: userData,
                      tipoSolicitud: 2, // 2 = constancia de estudios
                    ),
                  ),
                );
              },
            ),
            
            // Solicitar validación de prácticas profesionales
            ListTile(
              title: Text('Solicitar validación de prácticas profesionales'),
              leading: Icon(Icons.work),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SolicitudGenerica(
                      userData: userData,
                      tipoSolicitud: 3, // 3 = prácticas profesionales
                    ),
                  ),
                );
              },
            ),
            
            SizedBox(height: 30),
            
            // Ver mis solicitudes
            ListTile(
              title: Text('Ver mis solicitudes'),
              leading: Icon(Icons.list),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MisSolicitudes(userData: userData),
                  ),
                );
              },
            ),
            
            // Solicitudes aprobadas
            ListTile(
              title: Text('Solicitudes aprobadas'),
              leading: Icon(Icons.check_circle, color: Colors.green),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SolicitudesAprobadas(userData: userData),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}