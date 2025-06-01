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

  //get parsing data dari TicketSeatScreen
  late String movieId;
  late String movieName;
  late String posterPath;

  late List<String> selectedSeats;
  late List<String> seatDocIds;
  late double totalPrice;

  bool _isProcessing = false;

  @override

  //init data
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      movieId = args['movieId'] ?? '';
      movieName = args['movieName'] ?? '';
      selectedSeats = List<String>.from(args['selectedSeats'] ?? []);
      seatDocIds = List<String>.from(args['seatDocIds'] ?? []);
      totalPrice = args['totalPrice'] ?? 0.0;
      posterPath = args['posterPath'] ?? '';
    } else {
      movieId = '';
      movieName = '';
      selectedSeats = [];
      seatDocIds = [];
      totalPrice = 0.0;
      posterPath = '';
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

    await FirebaseFirestore.instance.collection('orders').add({
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'movieId': movieId,
      'movieName': movieName,
      'posterPath': posterPath,
      'selectedSeats': selectedSeats,
      'totalPrice': totalPrice,
      'timestamp': Timestamp.now(),
    });

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (posterPath.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w200$posterPath',
                      width: 80,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 120,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, size: 40),
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Movie: $movieName",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
      
        const SizedBox(height: 24),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        const SizedBox(height: 24),

          const Text(
            'Detail Transaksi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${selectedSeats.length} x Tiket',
                style: TextStyle(fontSize: 15, color: Colors.grey[800]),
              ),
              Text(
                selectedSeats.join(', ').toUpperCase(),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Harga',
                style: TextStyle(fontSize: 15, color: Colors.grey[800]),
              ),
              Text(
                'Rp ${totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 24),


            // const SizedBox(height: 16),
            // Text("Kursi: ${selectedSeats.join(', ')}", style: const TextStyle(fontSize: 16)),
            // const SizedBox(height: 16),
            // Text("Total Harga: Rp ${totalPrice.toStringAsFixed(0)}", style: const TextStyle(fontSize: 16)),
            const Spacer(),
            SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isProcessing ? null : _confirmOrder,
                        child: _isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                "Konfrimasi Tiket",
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                      ),
                ),
          ],
        ),
      ),
    );
  }
}