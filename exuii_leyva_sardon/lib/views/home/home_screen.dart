import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/seat_controller.dart';
import '../../models/seat_model.dart';
import '../../views/home/seat_selection_screen.dart';
import '../payment/payment_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asientos Disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              // Implementar logout
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
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
          return GridView.builder(
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
              return SeatWidget(
                seat: seat,
                onTap: () {
                  // Solo permitir seleccionar asientos disponibles
                  if (seat.estado == 'disponible') {
                    _showSeatSelectionDialog(context, [seat.id]);
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showQuantityDialog(context);
        },
        child: const Icon(Icons.add_shopping_cart),
        tooltip: 'Comprar asientos',
      ),
    );
  }

  void _showQuantityDialog(BuildContext context) {
    int quantity = 1;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Seleccionar cantidad'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() => quantity--);
                          }
                        },
                      ),
                      Text('$quantity', style: const TextStyle(fontSize: 24)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() => quantity++);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeatSelectionScreen(
                          quantity: quantity,
                        ),
                      ),
                    );
                  },
                  child: const Text('Siguiente'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSeatSelectionDialog(BuildContext context, List<String> seatIds) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Asiento seleccionado'),
          content: const Text('¿Desea comprar este asiento?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(seatIds: seatIds),
                  ),
                );
              },
              child: const Text('Comprar'),
            ),
          ],
        );
      },
    );
  }
}

class SeatWidget extends StatelessWidget {
  final SeatModel seat;
  final VoidCallback onTap;

  const SeatWidget({
    super.key,
    required this.seat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color seatColor;
    switch (seat.estado) {
      case 'disponible':
        seatColor = Colors.green;
        break;
      case 'ocupado':
        seatColor = Colors.red;
        break;
      case 'reservado':
        seatColor = Colors.yellow;
        break;
      default:
        seatColor = Colors.grey;
    }

    return GestureDetector(
      onTap: onTap,
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
  }
}