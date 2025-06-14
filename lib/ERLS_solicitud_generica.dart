import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
  File? _selectedImage;
  bool _isLoading = false;
  bool _isPickingImage = false;

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
Presente.-

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

      case 3: // Prácticas profesionales (placeholder para futuro)
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

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    
    setState(() {
      _isPickingImage = true;
    });
    
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        print('Imagen seleccionada: ${pickedFile.path}');
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;
    
    try {
      print('Iniciando subida de imagen...');
      
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String tipoNombre = widget.tipoSolicitud == 1 ? 'separacion' : 
                         widget.tipoSolicitud == 2 ? 'constancia' : 'practicas';
      String fileName = 'vouchers/solicitud_${tipoNombre}_${widget.userData['codigo']}_$timestamp.jpg';
      
      print('Nombre del archivo: $fileName');
      
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploaded_by': widget.userData['codigo'],
          'tipo_solicitud': tipoNombre,
        },
      );
      
      UploadTask uploadTask = storageRef.putFile(_selectedImage!, metadata);
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('Progreso: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
      });
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('URL de descarga obtenida: $downloadUrl');
      
      return downloadUrl;
      
    } catch (e) {
      print('Error detallado al subir imagen: $e');
      
      String errorMessage = 'Error al subir imagen';
      if (e.toString().contains('permission-denied')) {
        errorMessage = 'Sin permisos para subir archivos. Verifica las reglas de Firebase Storage.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Error de conexión. Verifica tu internet.';
      } else if (e.toString().contains('quota-exceeded')) {
        errorMessage = 'Cuota de almacenamiento excedida.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      return null;
    }
  }

  Future<void> _enviarSolicitud() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debe seleccionar una imagen del voucher'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!await _selectedImage!.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El archivo seleccionado no existe'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
              child: Text('Siguiente'),
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
      print('Iniciando proceso de envío...');
      
      String? voucherUrl = await _uploadImage();
      print('Resultado de subida: $voucherUrl');
      
      if (voucherUrl != null && voucherUrl.isNotEmpty) {
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
          'voucher': voucherUrl,
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
        
      } else {
        print('Error: No se obtuvo URL del voucher');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar la imagen. Intenta nuevamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
      body: Padding(
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
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voucher de pago',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _selectedImage != null 
                                ? 'Imagen seleccionada ✓' 
                                : 'Seleccione voucher de pago',
                            style: TextStyle(
                              color: _selectedImage != null 
                                  ? Colors.green 
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isPickingImage ? null : _pickImage,
                      icon: _isPickingImage 
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.image),
                      label: Text(_isPickingImage ? 'Cargando...' : 'Seleccionar'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
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
                  Text('• Envíe una foto nítida del voucher'),
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
    );
  }
}