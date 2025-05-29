import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalpbb/db/firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TicketSummaryScreen extends StatefulWidget {
  const TicketSummaryScreen({ Key? key }) : super(key: key);

  @override
  _TicketseatState createState() => _TicketseatState();
}

class _TicketseatState extends State<TicketSummaryScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  late String movieId;
  late String movieName;
  late List<String> selectedSeats;
  late List<String> seatDocIds;
  late double totalPrice;

  bool _isProcessing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      movieId = args['movieId'] ?? '';
      movieName = args['movieName'] ?? '';
      selectedSeats = List<String>.from(args['selectedSeats'] ?? []);
      seatDocIds = List<String>.from(args['seatDocIds'] ?? []);
      totalPrice = args['totalPrice'] ?? 0.0;
    } else {
      movieId = '';
      movieName = '';
      selectedSeats = [];
      seatDocIds = [];
      totalPrice = 0.0;
    }
  }

  Future<void> _confirmOrder() async {
    setState(() { _isProcessing = true; });

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (String seatDocId in seatDocIds) {
        DocumentReference seatRef = _firestoreService.getSeatsCollection(movieId).doc(seatDocId);
        batch.update(seatRef, {
          'status': 'booked',
          'userId': FirebaseAuth.instance.currentUser?.uid,
          'timestamp': Timestamp.now(),
        });
      }
      await batch.commit();

      //

      Navigator.popUntil(context, ModalRoute.withName('home'));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('bad: $e')),
      );
    } finally {
      setState(() { _isProcessing = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Konfirmasi Tiket",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Movie: $movieName", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text("Kursi: ${selectedSeats.join(', ')}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text("Total Harga: Rp ${totalPrice.toStringAsFixed(0)}", style: const TextStyle(fontSize: 16)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _confirmOrder,
                child: _isProcessing
                    ? const CircularProgressIndicator()
                    : const Text("Konfirmasi Order"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}