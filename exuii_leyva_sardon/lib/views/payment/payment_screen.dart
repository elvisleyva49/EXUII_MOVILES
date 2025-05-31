import 'package:flutter/material.dart';
import '../../controllers/seat_controller.dart';

class PaymentScreen extends StatefulWidget {
  final List<String> seatIds;

  const PaymentScreen({super.key, required this.seatIds});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Método de Pago')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(labelText: 'Número de Tarjeta'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el número de tarjeta';
                  }
                  if (value.length < 16) {
                    return 'El número de tarjeta debe tener 16 dígitos';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _expiryDateController,
                decoration:
                    const InputDecoration(labelText: 'Fecha de Vencimiento (MM/AA)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la fecha de vencimiento';
                  }
                  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                    return 'Formato inválido (MM/AA)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(labelText: 'CVV'),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el CVV';
                  }
                  if (value.length < 3) {
                    return 'El CVV debe tener al menos 3 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isProcessing
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _processPayment,
                      child: const Text('Pagar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isProcessing = true);
      
      // Simular procesamiento de pago
      await Future.delayed(const Duration(seconds: 2));
      
      try {
        await SeatController().updateSeatsStatus(widget.seatIds);
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text('Pago Exitoso'),
              content: const Text('Su compra se ha realizado con éxito.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar el pago: $e')),
        );
      } finally {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
}