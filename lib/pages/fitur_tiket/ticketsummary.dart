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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String movieId;
  late String movieName;
  late String posterPath;

  late List<String> selectedSeats;
  late List<String> seatDocIds;
  late double totalPrice;

  _TicketseatState() {
    movieId = '';
    movieName = '';
    posterPath = '';
    selectedSeats = [];
    seatDocIds = [];
    totalPrice = 0.0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      movieId = args['movieId'] ?? '';
      movieName = args['movieName'] ?? '';
      selectedSeats = List<String>.from(args['selectedSeats'] ?? []);
      seatDocIds = List<String>.from(args['seatDocIds'] ?? []);
      totalPrice = args['totalPrice']?.toDouble() ?? 0.0; 
      posterPath = args['posterPath'] ?? '';

      if (movieId.isEmpty || selectedSeats.isEmpty || totalPrice <= 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: Informasi tiket tidak lengkap.')),
            );
            Navigator.of(context).pop(); 
          });
      }
    } else {
       WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Gagal memuat detail tiket.')),
          );
          Navigator.of(context).pop(); 
       });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleConfirmation() async {
    if (!mounted) return;
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (String seatDocId in seatDocIds) {
        DocumentReference seatRef = _firestoreService.getSeatsCollection(movieId).doc(seatDocId);
        batch.update(seatRef, {
          'status': 'booked',
          'userId': _auth.currentUser?.uid,
          'timestamp': Timestamp.now(),
        });
      }
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tiket berhasil dikonfirmasi!')),
      );
      Navigator.popUntil(context, ModalRoute.withName('home'));

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengkonfirmasi pesanan: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (movieId.isEmpty && selectedSeats.isEmpty && totalPrice == 0.0 && ModalRoute.of(context)?.settings.arguments != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Konfirmasi Tiket")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (movieId.isEmpty && selectedSeats.isEmpty && totalPrice == 0.0) {
       return Scaffold(
        appBar: AppBar(title: const Text("Konfirmasi Tiket")),
        body: const Center(child: Text("Tidak ada data tiket.")),
      );
    }


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
                    // movieName can be long, ensure it's handled
                    "Movie: ${movieName.isNotEmpty ? movieName : 'Unknown Movie'}",
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
                  '${selectedSeats.isNotEmpty ? selectedSeats.length : 0} x Tiket',
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                Text(
                  selectedSeats.isNotEmpty ? selectedSeats.join(', ').toUpperCase() : 'N/A',
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
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleConfirmation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
                child: const Text("Konfirmasi Pesanan"),
              ),
            ),
            const Spacer(), 
          ],
        ),
      ),
    );
  }
}
