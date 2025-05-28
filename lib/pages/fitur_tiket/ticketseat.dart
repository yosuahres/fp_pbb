import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalpbb/db/firestore.dart'; 
import 'package:finalpbb/models/seat_model.dart';
import 'dart:math' as math;

class TicketSeatScreen extends StatefulWidget {
  const TicketSeatScreen({Key? key}) : super(key: key);

  @override
  _TicketSeatScreenState createState() => _TicketSeatScreenState();
}

class _TicketSeatScreenState extends State<TicketSeatScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  List<Seat> _allSeats = [];
  final List<String> _selectedSeatDocIds = []; 
  final double _seatPrice = 50000.0;
  
  bool _isLoading = true;

  final int _numRows = 5;
  final int _numCols = 8;

  @override
  void initState() {
    super.initState();
    _LoadSeats();
  }

  Future<void> _LoadSeats() async {
    await _firestoreService.initializeDefaultSeats(_numRows, _numCols);
    _loadSeats();
  }

  void _loadSeats() {
    _firestoreService.getSeats().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _allSeats = snapshot.docs.map((doc) => Seat.fromFirestore(doc)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _allSeats = [];
          _isLoading = false;
        });
      }
    }, onError: (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading seats: $error")),
      );
    });
  }

  void _onSeatTap(Seat seat) {
    if (seat.status == 'booked') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${seat.seatId} is already booked.')),
      );
      return;
    }

    setState(() {
      if (_selectedSeatDocIds.contains(seat.docId)) {
        _selectedSeatDocIds.remove(seat.docId);
      } else {
        _selectedSeatDocIds.add(seat.docId);
      }
    });
  }

  Color _getSeatColor(Seat seat) {
    if (seat.status == 'booked') {
      return Colors.grey.shade400; 
    } else if (_selectedSeatDocIds.contains(seat.docId)) {
      return Colors.blue.shade400; 
    } else {
      return Colors.blueGrey.shade900;
    }
  }

  Future<void> _bookSelectedSeats() async {
    if (_selectedSeatDocIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one seat.')),
      );
      return;
    }

    setState(() { _isLoading = true; }); 

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (String seatDocId in _selectedSeatDocIds) {
        Seat s = _allSeats.firstWhere((seat) => seat.docId == seatDocId);

        DocumentReference seatRef = _firestoreService.seats.doc(seatDocId);
        batch.update(seatRef, {
          'status': 'booked',
          'userId': FirebaseAuth.instance.currentUser?.uid,
          'timestamp': Timestamp.now(),
        });
      }
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selectedSeatDocIds.length} seat(s) booked successfully!')),
      );
      setState(() {
        _selectedSeatDocIds.clear(); 
        _isLoading = false;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking seats: $e')),
      );
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Seat> currentlySelectedSeats = _allSeats
        .where((seat) => _selectedSeatDocIds.contains(seat.docId))
        .toList();
    String selectedSeatNames = currentlySelectedSeats.map((s) => s.seatId).join(', ');
    double totalPrice = currentlySelectedSeats.length * _seatPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('nama tempat bioskop**'),
        // backgroundColor: Colors.grey.shade50,
      ),
      body: Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
      ),

      child: _isLoading && _allSeats.isEmpty 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
                  child: Column(
                    children: [
                      Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _legendItem(Colors.blueGrey.shade900, "Tersedia"),
                                _legendItem(Colors.grey.shade400, "Tidak Tersedia"),
                                _legendItem(Colors.blue.shade400, "Pilihanmu"),
                              ],
                            ),
                          ),
                      // const SizedBox(height: 8),
                        const Divider(
                        thickness: 1,
                        color: Colors.grey,
                        height: 24,
                      ),
                    ],
                  ),
                ),
                
                // Expanded(
                //   child: _allSeats.isEmpty && !_isLoading
                //       ? const Center(child: Text("No seats available or failed to load."))
                //       : GridView.builder(
                //           padding: const EdgeInsets.all(16.0),
                //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                //             crossAxisCount: _numCols, 
                //             crossAxisSpacing: 8.0,
                //             mainAxisSpacing: 8.0,
                //             childAspectRatio: 1.2, 
                //           ),
                //           itemCount: _allSeats.length,
                //           itemBuilder: (context, index) {
                //             final seat = _allSeats[index];
                //             return InkWell(
                //               onTap: () => _onSeatTap(seat),
                //               child: Container(
                //                 decoration: BoxDecoration(
                //                   color: _getSeatColor(seat),
                //                   borderRadius: BorderRadius.circular(5.0),
                //                   border: Border.all(color: Colors.black26),
                //                 ),
                //                 child: Center(
                //                   child: Text(
                //                     seat.seatId,
                //                     style: TextStyle(
                //                       color: _getSeatColor(seat) == Colors.blueGrey.shade900 || _getSeatColor(seat) == Colors.blue.shade400 
                //                       ? Colors.white 
                //                       : Colors.grey.shade700,
                //                       fontWeight: FontWeight.bold,
                //                       fontSize: 12,
                //                     ),
                //                   ),
                //                 ),
                //               ),
                //             );
                //           },
                //         ),

                // ),

                // ...existing code...
Expanded(
  child: _allSeats.isEmpty && !_isLoading
      ? const Center(child: Text("No seats available or failed to load."))
      : Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _numCols,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.2,
                ),
                itemCount: _allSeats.length,
                itemBuilder: (context, index) {
                  final seat = _allSeats[index];
                  return InkWell(
                    onTap: () => _onSeatTap(seat),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getSeatColor(seat),
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: Center(
                        child: Text(
                          seat.seatId,
                          style: TextStyle(
                            color: _getSeatColor(seat) == Colors.blueGrey.shade900 ||
                                    _getSeatColor(seat) == Colors.blue.shade400
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Movie screen representation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 60),
              child: SizedBox(
                height: 20,
                width: double.infinity,
                child: CustomPaint(
                  painter: MovieScreenPainter(),
                ),
              ),
            ),
          ],
        ),
),
// ...existing code...
                
              // if (_selectedSeatDocIds.isNotEmpty)  
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Total Harga',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 32,
                            width: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            color: Colors.grey.shade400,
                          ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Tempat Duduk',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              currentlySelectedSeats.isEmpty
                                  ? const Text(
                                      "Kursi belum dipilih",
                                      style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    )
                                  : Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      alignment: WrapAlignment.center,
                                      children: currentlySelectedSeats.map((seat) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.blueGrey.shade900,
                                            borderRadius: BorderRadius.circular(5.0),
                                            border: Border.all(color: Colors.black26),
                                          ),
                                          child: Text(
                                            seat.seatId,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Action buttons section
                      Row(
                        children: [
                          // Expanded(
                          //   child: ElevatedButton(
                          //     style: ElevatedButton.styleFrom(
                          //       padding: const EdgeInsets.symmetric(vertical: 12),
                          //     ),
                          //     onPressed: _selectedSeatDocIds.isNotEmpty && !_isLoading
                          //         ? () {
                          //             setState(() {
                          //               _selectedSeatDocIds.clear();
                          //             });
                          //           }
                          //         : null,
                          //     child: const Text(
                          //       'Clear Picks',
                          //       style: TextStyle(fontSize: 16, color: Colors.black),
                          //     ),
                          //   ),
                          // ),

                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero, // No curve
                                ),
                                backgroundColor: Colors.blueGrey.shade900,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: _selectedSeatDocIds.isNotEmpty && !_isLoading
                                  ? () {
                                      Navigator.pushNamed(context, 'ticketsummary');
                                    }
                                  : null,
                              child: Text(
                                'RINGKASAN ORDER',
                                style: TextStyle(fontSize: 14, color: Colors.yellow.shade700),
                              ),
                            ),
                          ),
                          
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 15, height: 15, color: color, margin: const EdgeInsets.only(right: 6)),
        Text(text),
      ],
    );
  }
}

class MovieScreenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    // Draw a simple arc (curve) facing up (towards the seats)
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    canvas.drawArc(
      rect,
      math.pi, // Start at 180 degrees (left)
      -math.pi, // Sweep -180 degrees (to right, facing up)
      false,
      paint,
    );

    // Draw "SCREEN" text above the curve, centered
    final textPainter = TextPainter(
      text: TextSpan(
        text: "LAYAR BIOSKOP",
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          // letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, 0),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
