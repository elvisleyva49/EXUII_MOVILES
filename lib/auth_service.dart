import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserData = 'userData';
  static const String _keyUserRole = 'userRole';

  // Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpia todos los datos guardados
    // O específicamente:
    // await prefs.remove(_keyIsLoggedIn);
    // await prefs.remove(_keyUserData);
    // await prefs.remove(_keyUserRole);
  }

  // Verificar si está logueado
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Guardar sesión (úsalo en tu login)
  static Future<void> saveSession(Map<String, dynamic> userData, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserData, userData.toString());
    await prefs.setString(_keyUserRole, role);
  }

  // Mostrar diálogo de confirmación para cerrar sesión
  static void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Cerrar Sesión'),
            ],
          ),
          content: Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cerrar diálogo
                await logout();
                // Navegar al login y limpiar stack
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', // O la ruta de tu pantalla de login
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}