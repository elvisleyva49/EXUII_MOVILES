import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SolicitudGenerica extends StatefulWidget {
  final Map<String, dynamic> userData;
  final int tipoSolicitud; // 1 = separación, 2 = constancia, 3 = prácticas
  
  SolicitudGenerica({
    required this.userData, 
    required this.tipoSolicitud
  });

  @override
  _SolicitudGenericaState createState() => _SolicitudGenericaState();
}

class _SolicitudGenericaState extends State<SolicitudGenerica> {
  late TextEditingController _textController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _generateSolicitudText());
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _getTipoNombre() {
    switch (widget.tipoSolicitud) {
      case 1:
        return 'Separación de Ciclo';
      case 2:
        return 'Constancia de Estudios';
      case 3:
        return 'Prácticas Profesionales';
      default:
        return 'Solicitud';
    }
  }

  String _generateSolicitudText() {
    String fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());
    
    switch (widget.tipoSolicitud) {
      case 1: // Separación de ciclo
        return '''UNIVERSIDAD PRIVADA DE TACNA
FACULTAD DE ${widget.userData['facultad']}
ESCUELA PROFESIONAL DE ${widget.userData['escuela']}

Tacna, $fecha

Señor
Decano de la Facultad de ${widget.userData['facultad']}
Presente.

Asunto: Solicitud de Separación de Ciclo

Yo, quien suscribe, ${widget.userData['nombres']} ${widget.userData['apellidos']}, identificado con DNI N.° ${widget.userData['dni']} y con código de estudiante N.° ${widget.userData['codigo']}, perteneciente a la Escuela Profesional de ${widget.userData['escuela']}, me dirijo a usted con el debido respeto para solicitar formalmente la separación del ciclo académico correspondiente al presente semestre.

El motivo de mi solicitud obedece a razones de carácter personal que me impiden continuar con normalidad mis estudios durante el presente ciclo académico. Me comprometo a regularizar mi situación académica en el siguiente periodo correspondiente, conforme a los reglamentos de la universidad.

Agradezco de antemano su comprensión y quedo atento(a) a su aprobación para continuar con el trámite correspondiente.

Sin otro particular, me despido.

Atentamente,

Firma del estudiante

${widget.userData['nombres']} ${widget.userData['apellidos']}
Código: ${widget.userData['codigo']}
DNI: ${widget.userData['dni']}''';

      case 2: // Constancia de estudios
        return '''UNIVERSIDAD PRIVADA DE TACNA
FACULTAD DE ${widget.userData['facultad']}
ESCUELA PROFESIONAL DE ${widget.userData['escuela']}

Tacna, $fecha

Señor
Decano de la Facultad de ${widget.userData['facultad']}
Presente.–

Asunto: Solicitud de Constancia de Estudios

Yo, quien suscribe, ${widget.userData['nombres']} ${widget.userData['apellidos']}, identificado(a) con DNI N.° ${widget.userData['dni']} y con código de estudiante N.° ${widget.userData['codigo']}, perteneciente a la Escuela Profesional de ${widget.userData['escuela']}, me dirijo a usted con el debido respeto para solicitar la expedición de una constancia de estudios que acredite mi situación académica en la Universidad Privada de Tacna.

La constancia de estudios será utilizada para los trámites correspondientes ante la institución que lo requiera. Agradezco de antemano la atención brindada y quedo atento(a) al tiempo y forma de entrega de dicho documento.

Sin otro particular, me despido.

Atentamente,

Firma del estudiante

${widget.userData['nombres']} ${widget.userData['apellidos']}
Código: ${widget.userData['codigo']}
DNI: ${widget.userData['dni']}''';

      case 3: // Prácticas profesionales
        return '''UNIVERSIDAD PRIVADA DE TACNA
FACULTAD DE ${widget.userData['facultad']}
ESCUELA PROFESIONAL DE ${widget.userData['escuela']}

Tacna, $fecha

Señor
Decano de la Facultad de ${widget.userData['facultad']}
Presente.-

Asunto: Solicitud de Validación de Prácticas Profesionales

Yo, quien suscribe, ${widget.userData['nombres']} ${widget.userData['apellidos']}, identificado con DNI N.° ${widget.userData['dni']} y con código de estudiante N.° ${widget.userData['codigo']}, perteneciente a la Escuela Profesional de ${widget.userData['escuela']}, me dirijo a usted con el debido respeto para solicitar la validación de mis prácticas profesionales.

[Detalles específicos de las prácticas profesionales]

Sin otro particular, me despido.

Atentamente,

Firma del estudiante

${widget.userData['nombres']} ${widget.userData['apellidos']}
Código: ${widget.userData['codigo']}
DNI: ${widget.userData['dni']}''';

      default:
        return '';
    }
  }

  Future<void> _enviarSolicitud() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar envío'),
          content: Text('Revise que los datos estén correctos antes de enviar.'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Enviar'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _procesarEnvio();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _procesarEnvio() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Guardando solicitud en Firestore...');
      
      Map<String, dynamic> solicitudData = {
        'usuario_id': widget.userData['id'],
        'nombres': widget.userData['nombres'],
        'apellidos': widget.userData['apellidos'],
        'dni': widget.userData['dni'],
        'codigo': widget.userData['codigo'],
        'escuela': widget.userData['escuela'],
        'facultad': widget.userData['facultad'],
        'texto_solicitud': _textController.text,
        'estado': 'secretaria',
        'tipo': widget.tipoSolicitud,
        'fecha_solicitud': FieldValue.serverTimestamp(),
        'hora_solicitud': DateFormat('HH:mm:ss').format(DateTime.now()),
        'created_at': DateTime.now().toIso8601String(),
      };
      
      print('Datos a guardar: $solicitudData');
      
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('solicitud')
          .add(solicitudData);
      
      print('Documento creado con ID: ${docRef.id}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Solicitud enviada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
      
    } catch (e) {
      print('Error en procesarEnvío: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar solicitud: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitud de ${_getTipoNombre()}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Edite el texto si es necesario',
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Antes de enviar:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('• Revise que la redacción no tenga faltas ortográficas'),
                    Text('• Revise que sus datos estén correctamente escritos'),
                    Text('• Cualquier caso de estos serán motivo de rechazo'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _enviarSolicitud,
                  icon: _isLoading 
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.send),
                  label: Text(
                    _isLoading ? 'Enviando...' : 'Enviar Solicitud',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}