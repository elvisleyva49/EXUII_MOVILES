import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/seat_controller.dart';
import '../../models/seat_model.dart';
import '../../views/payment/payment_screen.dart';
import '../payment/payment_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final int quantity;

  const SeatSelectionScreen({super.key, required this.quantity});

  @override
  _SeatSelectionScreenState createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final List<String> _selectedSeats = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar ${widget.quantity} asientos'),
      ),
      body: StreamBuilder<List<SeatModel>>(
        stream: SeatController().getSeats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay asientos disponibles'));
          }

          final seats = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: seats.length,
                  itemBuilder: (context, index) {
                    final seat = seats[index];
                    final isSelected = _selectedSeats.contains(seat.id);
                    final isAvailable = seat.estado == 'disponible';

                    Color seatColor;
                    if (isSelected) {
                      seatColor = Colors.blue;
                    } else if (!isAvailable) {
                      seatColor = Colors.red;
                    } else {
                      seatColor = Colors.green;
                    }

                    return GestureDetector(
                      onTap: isAvailable
                          ? () {
                              setState(() {
                                if (isSelected) {
                                  _selectedSeats.remove(seat.id);
                                } else if (_selectedSeats.length <
                                    widget.quantity) {
                                  _selectedSeats.add(seat.id);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Solo puedes seleccionar ${widget.quantity} asientos'),
                                    ),
                                  );
                                }
                              });
                            }
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: seatColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(
                          child: Text(
                            seat.numero,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _selectedSeats.length == widget.quantity
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PaymentScreen(seatIds: _selectedSeats),
                            ),
                          );
                        }
                      : null,
                  child: Text(
                      'Continuar (${_selectedSeats.length}/${widget.quantity})'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}