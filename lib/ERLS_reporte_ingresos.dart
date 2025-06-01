import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // AGREGAR ESTA LÍNEA
class ReporteIngresos extends StatefulWidget {
  @override
  _ReporteIngresosState createState() => _ReporteIngresosState();
}
class _ReporteIngresosState extends State<ReporteIngresos> {
  // CAMBIAR ESTAS LÍNEAS para usar fecha peruana
  int mesSeleccionado = _getFechaPeruana().month;
  int anioSeleccionado = _getFechaPeruana().year;
  
  double ingresosVIP = 0;
  double ingresosGeneral = 0;
  bool cargando = true;
  final List<String> meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];
  // AGREGAR ESTA FUNCIÓN ESTÁTICA
  static DateTime _getFechaPeruana() {
    DateTime utcNow = DateTime.now().toUtc();
    return utcNow.subtract(Duration(hours: 5)); // UTC-5 para Perú
  }
  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }
  Future<void> _cargarDatos() async {
    setState(() {
      cargando = true;
      ingresosVIP = 0;
      ingresosGeneral = 0;
    });
    try {
      QuerySnapshot conciertos = await FirebaseFirestore.instance
          .collection('conciertos')
          .get();
      for (var concierto in conciertos.docs) {
        List<dynamic> asientos = concierto['asientos'];
        
        for (var asiento in asientos) {
          if (asiento['ocupado'] == true) {
            bool contarAsiento = true;
            
            // AGREGAR ESTA LÓGICA: Si existe fechaCompra, verificar que sea del mes/año seleccionado
            if (asiento.containsKey('fechaCompra')) {
              String fechaCompra = asiento['fechaCompra']; // formato: "dd/MM/yyyy HH:mm:ss"
              List<String> fechaParts = fechaCompra.split(' ')[0].split('/'); // Tomar solo la fecha
              
              if (fechaParts.length == 3) {
                int mesCompra = int.parse(fechaParts[1]);
                int anioCompra = int.parse(fechaParts[2]);
                
                // Solo contar si la compra fue en el mes/año seleccionado
                contarAsiento = (mesCompra == mesSeleccionado && anioCompra == anioSeleccionado);
              }
            } else {
              // MANTENER LÓGICA ORIGINAL: Para asientos sin fechaCompra, usar fecha del concierto
              String fechaConcierto = concierto['fecha']; // formato dd/mm/yyyy
              List<String> fechaParts = fechaConcierto.split('/');
              
              if (fechaParts.length == 3) {
                int mesConcierto = int.parse(fechaParts[1]);
                int anioConcierto = int.parse(fechaParts[2]);
                contarAsiento = (mesConcierto == mesSeleccionado && anioConcierto == anioSeleccionado);
              }
            }
            
            if (contarAsiento) {
              if (asiento['zona'] == 'VIP') {
                ingresosVIP += 150;
              } else {
                ingresosGeneral += 50;
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error cargando datos: $e');
    }
    setState(() {
      cargando = false;
    });
  }
  // CORREGIR EL GRÁFICO DE PASTEL - reducir altura y radio
  Widget _buildPieChart() {
    if (ingresosVIP == 0 && ingresosGeneral == 0) {
      return Container(
        height: 150, // Reducido de 200 a 150
        child: Center(
          child: Text('No hay datos para mostrar'),
        ),
      );
    }
    return Container(
      height: 220, // Reducido de 200 a 150
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: ingresosVIP,
              title: 'VIP\nS/.${ingresosVIP.toStringAsFixed(0)}',
              color: Colors.purple,
              radius: 80, // Reducido de 80 a 60
              titleStyle: TextStyle(color: Colors.white, fontSize: 10), // Reducido de 12 a 10
            ),
            PieChartSectionData(
              value: ingresosGeneral,
              title: 'General\nS/.${ingresosGeneral.toStringAsFixed(0)}',
              color: Colors.blue,
              radius: 80, // Reducido de 80 a 60
              titleStyle: TextStyle(color: Colors.white, fontSize: 10), // Reducido de 12 a 10
            ),
          ],
          centerSpaceRadius: 30, // Reducido de 40 a 30
        ),
      ),
    );
  }
  // CORREGIR EL GRÁFICO DE BARRAS - reducir tamaño de fuente del eje Y
  Widget _buildBarChart() {
    if (ingresosVIP == 0 && ingresosGeneral == 0) {
      return Container(
        height: 200,
        child: Center(
          child: Text('No hay datos para mostrar'),
        ),
      );
    }
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          maxY: (ingresosVIP > ingresosGeneral ? ingresosVIP : ingresosGeneral) * 1.2,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: ingresosVIP,
                  color: Colors.purple,
                  width: 40,
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: ingresosGeneral,
                  color: Colors.blue,
                  width: 40,
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return Text('VIP');
                    case 1:
                      return Text('General');
                    default:
                      return Text('');
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40, // <-- deja 40px de espacio a la izquierda para las etiquetas
                getTitlesWidget: (value, meta) {
                  return Text(
                    'S/.${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reporte de Ingresos'),
        // AGREGAR INDICADOR DE ZONA HORARIA
        actions: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Center(
              child: Text(
                'Perú (UTC-5)',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: cargando
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AGREGAR INDICADOR DE FECHA ACTUAL PERUANA
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Fecha actual (Perú): ${DateFormat('dd/MM/yyyy HH:mm').format(_getFechaPeruana())}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                    ),
                  ),
                  
                  // MANTENER TODO EL RESTO IGUAL
                  Row(
                    children: [
                      Text('Mes: '),
                      DropdownButton<int>(
                        value: mesSeleccionado,
                        items: List.generate(12, (index) {
                          return DropdownMenuItem(
                            value: index + 1,
                            child: Text(meses[index]),
                          );
                        }),
                        onChanged: (valor) {
                          setState(() {
                            mesSeleccionado = valor!;
                          });
                          _cargarDatos();
                        },
                      ),
                      SizedBox(width: 20),
                      Text('Año: '),
                      DropdownButton<int>(
                        value: anioSeleccionado,
                        items: [2024, 2025, 2026].map((anio) {
                          return DropdownMenuItem(
                            value: anio,
                            child: Text('$anio'),
                          );
                        }).toList(),
                        onChanged: (valor) {
                          setState(() {
                            anioSeleccionado = valor!;
                          });
                          _cargarDatos();
                        },
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 30),
                  
                  Text(
                    'Distribución de Ingresos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  _buildPieChart(),
                  
                  SizedBox(height: 30),
                  
                  Text(
                    'Comparación de Ingresos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  _buildBarChart(),
                  
                  SizedBox(height: 30),
                  
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Recaudado ${meses[mesSeleccionado - 1]} $anioSeleccionado:',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'S/. ${(ingresosVIP + ingresosGeneral).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text('VIP'),
                            Text(
                              'S/. ${ingresosVIP.toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text('General'),
                            Text(
                              'S/. ${ingresosGeneral.toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}