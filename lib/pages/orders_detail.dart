import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalpbb/db/firestore.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderData, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _cancelOrder() async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      final String movieId = widget.orderData['movieId'] ?? '';
      final List<dynamic> selectedSeats = widget.orderData['selectedSeats'] as List<dynamic>? ?? [];

      // Unbook seats
      for (String seatId in selectedSeats) {
        QuerySnapshot seatQuery = await _firestoreService.getSeatsCollection(movieId)
            .where('seatId', isEqualTo: seatId)
            .limit(1)
            .get();
        if (seatQuery.docs.isNotEmpty) {
          DocumentReference seatRef = seatQuery.docs.first.reference;
          batch.update(seatRef, {
            'status': 'available',
            'userId': FieldValue.delete(),
            'timestamp': FieldValue.delete(),
          });
        }
      }
      await batch.commit();

      // Delete the order document
      await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order successfully cancelled!')),
      );
      Navigator.popUntil(context, ModalRoute.withName('home')); // Go back to home, specifically orders tab
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String movieName = widget.orderData['movieName'] ?? 'N/A';
    final List<dynamic> selectedSeats = widget.orderData['selectedSeats'] as List<dynamic>? ?? [];
    final String totalPrice = widget.orderData['totalPrice']?.toString() ?? 'N/A';
    final String posterPath = widget.orderData['posterPath'] ?? '';
    final String movieId = widget.orderData['movieId'] ?? ''; // Assuming movieId is in orderData

    return Scaffold(
      appBar: AppBar(
        title: Text(movieName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (posterPath.isNotEmpty)
              Center(
                child: Image.network(
                  'https://image.tmdb.org/t/p/w500$posterPath',
                  height: 300,
                  fit: BoxFit.contain,
                ),
              )
            else
              const Center(child: Icon(Icons.movie, size: 100)),
            const SizedBox(height: 20),
            Text(
              movieName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Seats: ${selectedSeats.join(', ')}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Total Price: Rp$totalPrice',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to TicketSeatScreen for editing
                  Navigator.pushNamed(
                    context,
                    'ticketseat', // Assuming 'ticketseat' is the route name for TicketSeatScreen
                    arguments: {
                      'movieId': movieId,
                      'movieName': movieName,
                      'posterPath': posterPath,
                      'selectedSeats': selectedSeats,
                      'totalPrice': totalPrice,
                      'orderId': widget.orderId, // Pass the orderId
                      'isEditing': true, // Indicate that we are in edit mode
                    },
                  );
                },
                child: const Text('Edit Seats'),
              ),
            ),
            const SizedBox(height: 10), // Spacing between buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Cancel Order'),
                        content: const Text('Are you sure you want to cancel this order? This action cannot be undone.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Dismiss dialog
                            },
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Dismiss dialog
                              _cancelOrder(); // Execute cancellation
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Cancel Order', style: TextStyle(color: Colors.white)),
              ),
            ),
            // Add more details if needed
          ],
        ),
      ),
    );
  }
}
