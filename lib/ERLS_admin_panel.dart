import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ERLS_seat_view.dart';
import 'ERLS_reporte_ingresos.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final _nombreController = TextEditingController();
  final _lugarController = TextEditingController();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();

  // Variables para almacenar la fecha y hora seleccionadas
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
        // Formatear en dd/mm/yyyy como se maneja actualmente
        _fechaController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada ?? TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        _horaSeleccionada = picked;
        // Formatear en HH:mm como se maneja actualmente
        _horaController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _agregarConcierto() async {
    if (_nombreController.text.isEmpty || _lugarController.text.isEmpty ||
        _fechaController.text.isEmpty || _horaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complete todos los campos')),
      );
      return;
    }

    // Crear los 70 asientos por defecto
    List<Map<String, dynamic>> asientos = [];
    for (int fila = 1; fila <= 7; fila++) {
      for (int asiento = 1; asiento <= 10; asiento++) {
        String zona = (fila <= 2) ? 'VIP' : 'GENERAL';
        asientos.add({
          'fila': fila,
          'asiento': asiento,
          'zona': zona,
          'ocupado': false,
        });
      }
    }

    try {
      await FirebaseFirestore.instance.collection('conciertos').add({
        'nombre': _nombreController.text,
        'lugar': _lugarController.text,
        'fecha': _fechaController.text,
        'hora': _horaController.text,
        'asientos': asientos,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      _nombreController.clear();
      _lugarController.clear();
      _fechaController.clear();
      _horaController.clear();
      _fechaSeleccionada = null;
      _horaSeleccionada = null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Concierto agregado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar concierto')),
      );
    }
  }

  Future<void> _eliminarConcierto(String conciertoId) async {
    try {
      await FirebaseFirestore.instance
          .collection('conciertos')
          .doc(conciertoId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Concierto eliminado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel Admin'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReporteIngresos()),
              );
            },
            icon: Icon(Icons.analytics),
            tooltip: 'Reporte de Ingresos',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(labelText: 'Nombre del Concierto'),
                ),
                TextField(
                  controller: _lugarController,
                  decoration: InputDecoration(labelText: 'Lugar'),
                ),
                // Campo de fecha con selector
                TextField(
                  controller: _fechaController,
                  decoration: InputDecoration(
                    labelText: 'Fecha (dd/mm/yyyy)',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: _seleccionarFecha,
                    ),
                  ),
                ),
                // Campo de hora con selector
                TextField(
                  controller: _horaController,
                  decoration: InputDecoration(
                    labelText: 'Hora (HH:mm)',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: _seleccionarHora,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _agregarConcierto,
                  child: Text('Agregar Concierto'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('conciertos')
                  .orderBy('fechaCreacion', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var concierto = snapshot.data!.docs[index];
                    return ListTile(
                      title: Text(concierto['nombre']),
                      subtitle: Text('${concierto['fecha']} - ${concierto['hora']} - ${concierto['lugar']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _eliminarConcierto(concierto.id),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SeatView(
                              conciertoId: concierto.id,
                              conciertoNombre: concierto['nombre'],
                              isAdmin: true,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}