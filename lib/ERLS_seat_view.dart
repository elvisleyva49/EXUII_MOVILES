import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SeatView extends StatefulWidget {
  final String conciertoId;
  final String conciertoNombre;
  final bool isAdmin;

  SeatView({required this.conciertoId, required this.conciertoNombre, required this.isAdmin});

  @override
  _SeatViewState createState() => _SeatViewState();
}

class _SeatViewState extends State<SeatView> {
  List<Map<String, dynamic>> asientosSeleccionados = [];
  int cantidadAsientos = 0;
  bool mostrandoSeleccion = false;

    String _getFechaHoraPeruana() {
    // Crear fecha actual UTC
    DateTime utcNow = DateTime.now().toUtc();
    // Restar 5 horas para obtener hora peruana (UTC-5)
    DateTime peruTime = utcNow.subtract(Duration(hours: 5));
    // Formatear en formato peruano
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(peruTime);
  }

  Widget _buildSeat(Map<String, dynamic> asiento, int index) {
    bool isOcupado = asiento['ocupado'];
    bool isSeleccionado = asientosSeleccionados.any((a) => 
        a['fila'] == asiento['fila'] && a['asiento'] == asiento['asiento']);

    Color color;
    if (isOcupado) {
      color = Colors.red;
    } else if (isSeleccionado) {
      color = Colors.blue;
    } else {
      color = Colors.green;
    }

    return GestureDetector(
      onTap: widget.isAdmin ? null : () {
        if (!isOcupado && mostrandoSeleccion && asientosSeleccionados.length < cantidadAsientos) {
          setState(() {
            if (isSeleccionado) {
              asientosSeleccionados.removeWhere((a) => 
                  a['fila'] == asiento['fila'] && a['asiento'] == asiento['asiento']);
            } else {
              asientosSeleccionados.add(asiento);
            }
          });
        }
      },
      child: Container(
        width: 30,
        height: 30,
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: Text(
            '${asiento['asiento']}',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _mostrarSelectorCantidad() {
    showDialog(
      context: context,
      builder: (context) {
        int cantidad = 1;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Seleccionar cantidad de asientos'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: cantidad > 1 ? () {
                      setStateDialog(() {
                        cantidad--;
                      });
                    } : null,
                    icon: Icon(Icons.remove),
                  ),
                  Text('$cantidad', style: TextStyle(fontSize: 18)),
                  IconButton(
                    onPressed: () {
                      setStateDialog(() {
                        cantidad++;
                      });
                    },
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      cantidadAsientos = cantidad;
                      mostrandoSeleccion = true;
                      asientosSeleccionados.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Continuar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

double _calcularTotal() {
  double total = 0;
  for (var asiento in asientosSeleccionados) {
    if (asiento['zona'] == 'VIP') {
      total += 150;
    } else {
      total += 50;
    }
  }
  return total;
}

void _mostrarResumen() {
  if (asientosSeleccionados.length != cantidadAsientos) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Debe seleccionar ${cantidadAsientos} asientos')),
    );
    return;
  }

  double totalConIgv = _calcularTotal(); // El precio ya incluye IGV
  double subtotal = totalConIgv / 1.18; // Calcular el subtotal sin IGV
  double igv = totalConIgv - subtotal; // El IGV es la diferencia

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text('Resumen de Compra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Concierto: ${widget.conciertoNombre}'),
            SizedBox(height: 10),
            Text('Asientos seleccionados:'),
            ...asientosSeleccionados.map((asiento) => 
              Text('Fila ${asiento['fila']}, Asiento ${asiento['asiento']} (${asiento['zona']})')),
            SizedBox(height: 10),
            Text('Subtotal: S/.${subtotal.toStringAsFixed(2)}'),
            Text('IGV (18%): S/.${igv.toStringAsFixed(2)}'),
            Text('Total: S/.${totalConIgv.toStringAsFixed(2)}', 
                 style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Cancelar compra'),
                  content: Text('¿Está seguro que desea cancelar? Tendrá que comenzar el proceso de nuevo.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Cerrar confirmación
                        Navigator.pop(context); // Cerrar resumen
                        setState(() {
                          asientosSeleccionados.clear();
                          cantidadAsientos = 0;
                          mostrandoSeleccion = false;
                        });
                      },
                      child: Text('Sí, cancelar'),
                    ),
                  ],
                ),
              );
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Simulación simple de voucher
              bool? result = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Confirmar Pago'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('¿Confirma que ha realizado el pago?'),
                      SizedBox(height: 10),
                      Text('Total: S/.${_calcularTotal().toStringAsFixed(2)}'), // Ya incluye IGV
                      SizedBox(height: 10),
                      Text('Una vez confirmado, los asientos serán reservados.',
                           style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Confirmar Pago'),
                    ),
                  ],
                ),
              );

              if (result == true) {
                // Marcar asientos como ocupados
                await _marcarAsientosOcupados();
                Navigator.pop(context); // Cerrar resumen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('¡Pago exitoso! Asientos reservados.')),
                );
                setState(() {
                  asientosSeleccionados.clear();
                  cantidadAsientos = 0;
                  mostrandoSeleccion = false;
                });
              }
            },
            child: Text('Confirmar Pago'),
          ),
        ],
      );
    },
  );
}

  Future<void> _marcarAsientosOcupados() async {
    try {
      DocumentSnapshot conciertoDoc = await FirebaseFirestore.instance
          .collection('conciertos')
          .doc(widget.conciertoId)
          .get();
      
      List<dynamic> asientos = conciertoDoc['asientos'];
      
      for (var asientoSeleccionado in asientosSeleccionados) {
        for (int i = 0; i < asientos.length; i++) {
          if (asientos[i]['fila'] == asientoSeleccionado['fila'] && 
              asientos[i]['asiento'] == asientoSeleccionado['asiento']) {
            asientos[i]['ocupado'] = true;
            // NUEVA LÍNEA: Registrar fecha y hora de compra en hora peruana
            asientos[i]['fechaCompra'] = _getFechaHoraPeruana();
            break;
          }
        }
      }

      await FirebaseFirestore.instance
          .collection('conciertos')
          .doc(widget.conciertoId)
          .update({'asientos': asientos});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar pago')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conciertoNombre),
        actions: !widget.isAdmin && !mostrandoSeleccion ? [
          IconButton(
            onPressed: _mostrarSelectorCantidad,
            icon: Icon(Icons.shopping_cart),
          ),
        ] : null,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('conciertos')
            .doc(widget.conciertoId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<dynamic> asientos = snapshot.data!['asientos'];

          return Column(
            children: [
              // Indicador del escenario
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Text(
                  '🎤 CONCIERTO 🎤',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Zona VIP
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('VIP - S/.150', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      for (int fila = 1; fila <= 2; fila++)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: asientos
                              .where((a) => a['fila'] == fila)
                              .map((asiento) => _buildSeat(asiento, asientos.indexOf(asiento)))
                              .toList(),
                        ),
                      
                      SizedBox(height: 20),
                      
                      // Zona General
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('GENERAL - S/.50', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      for (int fila = 3; fila <= 7; fila++)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: asientos
                              .where((a) => a['fila'] == fila)
                              .map((asiento) => _buildSeat(asiento, asientos.indexOf(asiento)))
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Leyenda
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Container(width: 20, height: 20, color: Colors.green),
                        SizedBox(width: 5),
                        Text('Disponible'),
                      ],
                    ),
                    Row(
                      children: [
                        Container(width: 20, height: 20, color: Colors.red),
                        SizedBox(width: 5),
                        Text('Ocupado'),
                      ],
                    ),
                    if (mostrandoSeleccion)
                      Row(
                        children: [
                          Container(width: 20, height: 20, color: Colors.blue),
                          SizedBox(width: 5),
                          Text('Seleccionado'),
                        ],
                      ),
                  ],
                ),
              ),
              
              if (mostrandoSeleccion)
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Seleccionados: ${asientosSeleccionados.length}/$cantidadAsientos'),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                asientosSeleccionados.clear();
                                cantidadAsientos = 0;
                                mostrandoSeleccion = false;
                              });
                            },
                            child: Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: asientosSeleccionados.length == cantidadAsientos ? _mostrarResumen : null,
                            child: Text('Continuar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}