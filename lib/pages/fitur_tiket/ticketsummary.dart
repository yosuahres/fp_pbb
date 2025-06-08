import 'dart:async'; 

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalpbb/db/firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:finalpbb/services/paymentApi_service.dart'; 

class TicketSummaryScreen extends StatefulWidget {
  const TicketSummaryScreen({ Key? key }) : super(key: key);

  @override
  _TicketseatState createState() => _TicketseatState();
}

class _TicketseatState extends State<TicketSummaryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final PaymentService _paymentService = PaymentService(); 
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String movieId;
  late String movieName;
  late String posterPath;

  late List<String> selectedSeats;
  late List<String> seatDocIds;
  late double totalPrice;

  bool _isProcessingPayment = false; 
  String? _currentOrderId; 
  StreamSubscription? _orderStatusSubscription; 

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
    _orderStatusSubscription?.cancel(); 
    super.dispose();
  }

  Future<void> _finalizeOrderAndBookSeats(String orderId) async {
    if (!mounted) return; 
    setState(() { _isProcessingPayment = true; }); 
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (String seatDocId in seatDocIds) {
        DocumentReference seatRef = _firestoreService.getSeatsCollection(movieId).doc(seatDocId);
        batch.update(seatRef, {
          'status': 'booked',
          'userId': _auth.currentUser?.uid,
          'orderId': orderId,
          'timestamp': Timestamp.now(),
        });
      }
      await batch.commit();

      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'bookingStatus': 'confirmed', 
        'lastUpdated': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tiket berhasil dikonfirmasi dan dibayar!')),
      );
      Navigator.popUntil(context, ModalRoute.withName('home'));

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyelesaikan pesanan setelah pembayaran: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() { _isProcessingPayment = false; });
    }
  }


  Future<void> _handleShopeePayPayment() async {
    if (_auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu.')),
      );
      return;
    }
    if (totalPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total harga tidak valid.')),
      );
      return;
    }

    if (!mounted) return;
    setState(() { _isProcessingPayment = true; });

    final orderRef = FirebaseFirestore.instance.collection('orders').doc();
    _currentOrderId = orderRef.id;

    try {
      await orderRef.set({
        'orderId': _currentOrderId,
        'userId': _auth.currentUser?.uid,
        'userName': _auth.currentUser?.displayName ?? 'N/A',
        'userEmail': _auth.currentUser?.email ?? 'N/A',
        'movieId': movieId,
        'movieName': movieName,
        'posterPath': posterPath,
        'selectedSeats': selectedSeats,
        'totalPrice': totalPrice,
        'paymentMethod': 'shopeepay',
        'paymentStatus': 'pending_initiation', // Initial status
        'bookingStatus': 'pending_payment',
        'createdAt': Timestamp.now(),
        'lastUpdated': Timestamp.now(),
      });

      const String clientReturnUrl = "https://your-website.com/payment-callback/shopeepay";

      final paymentData = await _paymentService.initiateShopeePayCheckout(
        orderId: _currentOrderId!,
        amount: totalPrice,
        clientReturnUrl: clientReturnUrl,
      );

      if (paymentData != null && paymentData['redirectUrlApp'] != null) {
        final String shopeePayRedirectUrl = paymentData['redirectUrlApp']; 
        
        final Uri? uri = Uri.tryParse(shopeePayRedirectUrl);
        if (uri != null && await canLaunchUrl(uri)) {
          await orderRef.update({
            'paymentStatus': 'pending_shopeepay_confirmation', 
            'lastUpdated': Timestamp.now(),
          });
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          _listenForPaymentConfirmation(_currentOrderId!); 
        } else {
          throw 'Tidak dapat membuka URL ShopeePay: $shopeePayRedirectUrl';
        }
      } else {
        throw 'Gagal mendapatkan URL pembayaran ShopeePay dari server.';
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("Error during ShopeePay handling: $e");
      await FirebaseFirestore.instance.collection('orders').doc(_currentOrderId).update({
        'paymentStatus': 'failed_initiation',
        'errorMessage': e.toString(),
        'lastUpdated': Timestamp.now(),
      }).catchError((err) => debugPrint("Error updating order status to error: $err"));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error pembayaran ShopeePay: ${e.toString()}')),
      );
      setState(() { _isProcessingPayment = false; }); 
    }
  }

  void _listenForPaymentConfirmation(String orderId) {
    _orderStatusSubscription?.cancel(); 
    _orderStatusSubscription = FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .listen((orderSnapshot) {
      if (!mounted) {
        _orderStatusSubscription?.cancel();
        return;
      }

      if (orderSnapshot.exists) {
        final status = orderSnapshot.data()?['paymentStatus'] as String?;
        final bookingStatus = orderSnapshot.data()?['bookingStatus'] as String?;
        debugPrint("Order $orderId status update: paymentStatus=$status, bookingStatus=$bookingStatus");

        if (status == 'paid' && bookingStatus != 'confirmed') { 
          _orderStatusSubscription?.cancel(); 
          _finalizeOrderAndBookSeats(orderId);
        } else if (status == 'failed' || status == 'cancelled' || status == 'expired') {
          _orderStatusSubscription?.cancel();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pembayaran $status. Silakan coba lagi atau pilih metode lain.')),
          );
          setState(() { _isProcessingPayment = false; });
        } else if (status == 'pending_shopeepay_confirmation' || status == 'pending_initiation' || status == 'pending') {
          if (!_isProcessingPayment) {
             setState(() { _isProcessingPayment = true; }); 
          }
        } else if (bookingStatus == 'confirmed') {
            _orderStatusSubscription?.cancel();
            if (_isProcessingPayment) setState(() { _isProcessingPayment = false; });
            debugPrint("Order $orderId already confirmed.");
        }

      } else {
        debugPrint("Order $orderId not found during listening.");
        _orderStatusSubscription?.cancel();
        if (_isProcessingPayment) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error: Data pesanan tidak ditemukan.')),
            );
            setState(() { _isProcessingPayment = false; });
        }
      }
    }, onError: (error) {
        debugPrint("Error listening to order $orderId: $error");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error sinkronisasi status pembayaran: $error')),
        );
        if (_isProcessingPayment) setState(() { _isProcessingPayment = false; });
    });
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
            
            if (_isProcessingPayment)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Memproses pembayaran...", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text(
                      "Mohon selesaikan pembayaran di aplikasi ShopeePay.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else ...[
              const Text(
                'Pilih Metode Pembayaran:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.payment), 
                  label: const Text("Bayar dengan ShopeePay"),
                  onPressed: _isProcessingPayment ? null : _handleShopeePayPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE4D2D), 
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ],
            const Spacer(), 
          ],
        ),
      ),
    );
  }
}