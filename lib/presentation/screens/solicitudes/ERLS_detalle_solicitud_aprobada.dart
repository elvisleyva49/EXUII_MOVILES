import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class DetalleSolicitudAprobada extends StatelessWidget {
  final Map<String, dynamic> solicitudData;
  
  DetalleSolicitudAprobada({required this.solicitudData});

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

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    
    // Cargar fuente personalizada si es necesario
    // final font = await PdfGoogleFonts.nunitoRegular();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Marca de agua de aprobación
              pw.Container(
                alignment: pw.Alignment.center,
                margin: pw.EdgeInsets.only(bottom: 20),
                child: pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.green, width: 3),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Text(
                    'SOLICITUD APROBADA',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green,
                    ),
                  ),
                ),
              ),
              
              // Título del documento
              pw.Container(
                alignment: pw.Alignment.center,
                margin: pw.EdgeInsets.only(bottom: 20),
                child: pw.Text(
                  _getTipoString(solicitudData['tipo'] ?? 0).toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              
              // Contenido de la solicitud
              pw.Container(
                padding: pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text(
                  solicitudData['texto_solicitud'] ?? 'No hay contenido disponible',
                  style: pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
                ),
              ),
              
              pw.Spacer(),
              
              // Información de aprobación
              pw.Container(
                margin: pw.EdgeInsets.only(top: 30),
                padding: pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  border: pw.Border.all(color: PdfColors.green),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'INFORMACIÓN DE APROBACIÓN',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green800,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Esta solicitud ha sido revisada y aprobada por las autoridades competentes de la Universidad Privada de Tacna.',
                      style: pw.TextStyle(fontSize: 11),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Documento generado el: ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

Future<void> _downloadPdf(BuildContext context) async {
  try {
    final pdfData = await _generatePdf();
    
    // Usar solo compartir (no guardar directamente)
    await Printing.sharePdf(
      bytes: pdfData,
      filename: 'solicitud_aprobada.pdf',
    );
    
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitud Aprobada'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => _downloadPdf(context),
            tooltip: 'Descargar PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado de aprobación
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'SOLICITUD APROBADA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _getTipoString(solicitudData['tipo'] ?? 0),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Información del documento
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Documento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildInfoRow('Estudiante:', '${solicitudData['nombres']} ${solicitudData['apellidos']}'),
                    _buildInfoRow('Código:', solicitudData['codigo'] ?? 'No disponible'),
                    _buildInfoRow('DNI:', solicitudData['dni'] ?? 'No disponible'),
                    _buildInfoRow('Escuela:', solicitudData['escuela'] ?? 'No disponible'),
                    _buildInfoRow('Facultad:', solicitudData['facultad'] ?? 'No disponible'),
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
                    Row(
                      children: [
                        Icon(Icons.description, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Contenido de la Solicitud',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          // Marca de agua
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Transform.rotate(
                              angle: -0.5,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'APROBADO',
                                  style: TextStyle(
                                    color: Colors.green.withOpacity(0.6),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Contenido del texto
                          Text(
                            solicitudData['texto_solicitud'] ?? 'No hay contenido disponible',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Botón de descarga
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _downloadPdf(context),
                icon: Icon(Icons.download, size: 24),
                label: Text(
                  'Descargar PDF',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Información adicional
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.green[700]),
                      SizedBox(width: 8),
                      Text(
                        'Información importante',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Este documento ha sido oficialmente aprobado\n'
                    '• Puedes descargarlo en formato PDF\n'
                    '• Conserva este documento para tus registros\n'
                    '• En caso de dudas, contacta con la secretaría académica',
                    style: TextStyle(color: Colors.green[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
              value,
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}